# frozen_string_literal: true

require "forwardable"
require "strscan"
require "strings-ansi"
require "unicode/display_width"

require_relative "truncation/version"

module Strings
  class Truncation
    class Error < StandardError; end

    DEFAULT_OMISSION = "…"

    DEFAULT_LENGTH = 30

    ANSI_REGEXP  = /#{Strings::ANSI::ANSI_MATCHER}/.freeze
    RESET_REGEXP = /#{Regexp.escape(Strings::ANSI::RESET)}/.freeze
    END_REGEXP   = /\A(#{Strings::ANSI::ANSI_MATCHER})?\z/.freeze

    # Global instance
    #
    # @api private
    def self.__instance__
      @__instance__ ||= Truncation.new
    end

    class << self
      extend Forwardable

      delegate %i[truncate] => :__instance__
    end

    # Truncate a text at a given length (defualts to 30)
    #
    # @param [String] text
    #   the text to be truncated
    #
    # @param [Integer] truncate_at
    #   the width at which to truncate the text
    #
    # @param [String|Regexp] separator
    #   the character for splitting words
    #
    # @param [String] omission
    #   the string to use for displaying omitted content
    #
    # @param [String|Integer] position
    #   the position in text from which to omit content
    #
    # @example
    #   truncate("It is not down on any map; true places never are.")
    #   # => "It is not down on any map; tr…""
    #
    #   truncate("It is not down on any map; true places never are.", 15)
    #   # => "It is not down…""
    #
    #   truncate("It is not down on any map; true places never are.",
    #            separator: " ")
    #   # => "It is not down on any map;…"
    #
    #   truncate("It is not down on any map; true places never are.", 40,
    #            omission: "[...]")
    #   # => "It is not down on any map; true pla[...]"
    #
    # @api public
    def truncate(text, truncate_at = DEFAULT_LENGTH, length: nil, position: 0,
                 separator: nil, omission: DEFAULT_OMISSION)
      truncate_at = length if length

      return text if truncate_at.nil? || text.bytesize <= truncate_at.to_i

      return "" if truncate_at.zero?

      separator = Regexp.new(separator) if separator

      case position
      when :start
        truncate_start(text, truncate_at, omission, separator)
      when :middle
        truncate_middle(text, truncate_at, omission, separator)
      when :end
        truncate_from(0, text, truncate_at, omission, separator)
      when Numeric
        truncate_from(position, text, truncate_at, omission, separator)
      else
        raise Error, "unsupported position: #{position.inspect}"
      end
    end

    private

    # Truncate text at the start
    #
    # @param [String] text
    #   the text to truncate
    # @param [Integer] length
    #   the maximum length to truncate at
    # @param [String] omission
    #   the string to denote omitted content
    # @param [String|Regexp] separator
    #   the pattern or string to separate on
    #
    # @return [String]
    #   the truncated text
    #
    # @api private
    def truncate_start(text, length, omission, separator)
      text_width = display_width(Strings::ANSI.sanitize(text))
      omission_width = display_width(omission)
      return text if text_width == length
      return omission if omission_width == length

      from = [text_width - length, 0].max
      from += omission_width if from > 0
      words, = *slice(text, from, length - omission_width, separator: separator)

      "#{omission if from > 0}#{words}"
    end

    # Truncate text before the from position and after the length
    #
    # @param [Integer] from
    #   the position to start extracting from
    # @param [String] text
    #   the text to truncate
    # @param [Integer] length
    #   the maximum length to truncate at
    # @param [String] omission
    #   the string to denote omitted content
    # @param [String|Regexp] separator
    #   the pattern or string to separate on
    #
    # @return [String]
    #   the truncated text
    #
    # @api private
    def truncate_from(from, text, length, omission, separator)
      omission_width = display_width(omission)
      length_without_omission = length - omission_width
      length_without_omission -= omission_width if from > 0
      words, stop = *slice(text, from, length_without_omission,
                           separator: separator)

      "#{omission if from > 0}#{words}#{omission if stop}"
    end

    # Truncate text in the middle
    #
    # @param [String] text
    #   the text to truncate
    # @param [Integer] length
    #   the maximum length to truncate at
    # @param [String] omission
    #   the string to denote omitted content
    # @param [String|Regexp] separator
    #   the pattern or string to separate on
    #
    # @return [String]
    #   the truncated text
    #
    # @api private
    def truncate_middle(text, length, omission, separator)
      text_width = display_width(Strings::ANSI.sanitize(text))
      omission_width = display_width(omission)
      return text if text_width == length
      return omission if omission_width == length

      half_length = length / 2
      rem_length = half_length + length % 2
      half_omission = omission_width / 2
      rem_omission = half_omission + omission_width % 2

      before_words, = *slice(text, 0, half_length - half_omission,
                             separator: separator)

      after_words, = *slice(text, text_width - rem_length + rem_omission,
                            rem_length - rem_omission,
                            separator: separator)

      "#{before_words}#{omission}#{after_words}"
    end

    # Extract number of characters from a text starting at the from position
    #
    # @param [Integer] from
    #   the position to start from
    # @param [Integer] length
    #   the number of characters to extract
    # @param [String|Regexp] separator
    #   the string or pattern to use for splitting words
    #
    # @return [Array<String, Boolean>]
    #   return a substring and a stop flag
    #
    # @api private
    def slice(text, from, length, separator: nil)
      scanner = StringScanner.new(text)
      current_length = 0
      start_position = 0
      ansi_reset = false
      visible_char = false
      word_break = false
      stop = false
      words = []
      word = []
      char = nil

      while !(scanner.eos? || stop)
        if scanner.scan(RESET_REGEXP)
          unless scanner.eos?
            words << scanner.matched
            ansi_reset = false
          end
        elsif scanner.scan(ANSI_REGEXP)
          words << scanner.matched
          ansi_reset = true
        else
          if char =~ separator && start_position <= from
            word_break = start_position != from
          end

          char = scanner.getch
          char_width = display_width(char)
          start_position += char_width
          next if (start_position - char_width) < from

          visible_char = true
          current_length += char_width

          if char =~ separator
            if word_break
              word_break = false
              next
            end
            words << word.join
            word.clear
          end

          if current_length <= length || scanner.check(END_REGEXP)
            if separator
              word << char unless word_break
            else
              words << char
            end
          else
            stop = true
          end
        end
      end

      return ["", stop] unless visible_char

      words << word.join if !word.empty? && scanner.eos?

      words << Strings::ANSI::RESET if ansi_reset

      [words.join, stop]
    end

    # Visible width of a string
    #
    # @return [Integer]
    #
    # @api private
    def display_width(string)
      Unicode::DisplayWidth.of(string)
    end
  end # Truncation
end # Strings
