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

    ANSI_REGEXP = Regexp.new(Strings::ANSI::ANSI_MATCHER)
    RESET_REGEXP = Regexp.new(Regexp.escape(Strings::ANSI::RESET))

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
    #   the string to use for displaying truncated content
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
    def truncate(text, truncate_at = DEFAULT_LENGTH, separator: nil, length: nil,
                 omission: DEFAULT_OMISSION, from: 0)
      truncate_at = length if length

      return text if truncate_at.nil? || text.bytesize <= truncate_at.to_i

      return "" if truncate_at.zero?

      omission_width = display_width(omission)
      length_without_omission = truncate_at - omission_width
      length_without_omission -= omission_width if from > 0
      words, stop = *slice(text, from, length_without_omission,
                           separator: separator)

      "#{omission if from > 0}#{words}#{omission if stop}"
    end

    private

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
      stop = false
      words = []
      word = []

      while !(scanner.eos? || stop)
        if scanner.scan(RESET_REGEXP)
          words << scanner.matched
          ansi_reset = false
        elsif scanner.scan(ANSI_REGEXP)
          words << scanner.matched
          ansi_reset = true
        else
          char = scanner.getch
          char_width = display_width(char)
          start_position += char_width
          next if start_position <= from
          current_length += char_width

          if char == separator
            words << word.join
            word.clear
          end

          if current_length <= length
            if separator
              word << char
            else
              words << char
            end
          else
            stop = true
          end
        end
      end

      words << word.join if words.empty?

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
