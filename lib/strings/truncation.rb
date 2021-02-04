# frozen_string_literal: true

require "forwardable"
require "strscan"
require "strings-ansi"
require "unicode/display_width"

require_relative "truncation/version"

module Strings
  class Truncation
    class Error < StandardError; end

    DEFAULT_OMISSION = "…".freeze

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
    # @param [String] separator
    #   the character for splitting words
    #
    # @param [String] omission
    #   the string to use for ending truncated sentence
    #
    # @example
    #   Strings::Truncate.truncate("It is not down on any map; true places never are.")
    #   # => "It is not down on any map; tr…""
    #
    #   Strings::Truncate.truncate("It is not down on any map; true places never are.", 15)
    #   # => "It is not down…""
    #
    #   Strings::Truncate.truncate("It is not down on any map; true places never are.", separator: " " )
    #   # => "It is not down on any map;…"
    #
    #   Strings::Truncate.truncate("It is not down on any map; true places never are.", 40, omission: "... (see more)" )
    #   # => "It is not down on any map;...(continued)"
    #
    # @api public
    def truncate(text, truncate_at = DEFAULT_LENGTH, separator: nil, length: nil,
                 omission: DEFAULT_OMISSION)
      truncate_at = length if length

      if text.bytesize <= truncate_at.to_i || truncate_at.to_i.zero?
        return text
      end

      length_without_omission = truncate_at - display_width(omission)
      scanner = StringScanner.new(text)
      length = 0
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
          length += display_width(char)

          if char == separator
            words << word.join
            word.clear
          end

          if length <= length_without_omission
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

      "#{words.join}#{omission if stop}"
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
