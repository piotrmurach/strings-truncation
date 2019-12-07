# frozen_string_literal: true

require "strscan"
require "strings-ansi"
require "unicode/display_width"

require_relative "truncation/version"

module Strings
  module Truncation
    class Error < StandardError; end

    DEFAULT_TRAILING = '…'.freeze

    DEFAULT_LENGTH = 30

    ANSI_REGEXP = Regexp.new(Strings::ANSI::ANSI_MATCHER)
    RESET_REGEXP = Regexp.new(Regexp.escape(Strings::ANSI::RESET))

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
    # @param [String] trailing
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
    #   Strings::Truncate.truncate("It is not down on any map; true places never are.", 40, trailing: '... (see more)' )
    #   # => "It is not down on any map;...(continued)"
    #
    # @api public
    def truncate(text, truncate_at = DEFAULT_LENGTH, separator: nil,
                trailing: DEFAULT_TRAILING)
      if display_width(text) <= truncate_at.to_i || truncate_at.to_i.zero?
        return text
      end

      length_without_trailing = truncate_at - display_width(trailing)
      scanner = StringScanner.new(text)
      length = 0
      ansi_reset = false
      stop = false
      words = []
      word = []

      while !stop
        if scanner.scan(RESET_REGEXP)
          word << scanner[0]
          ansi_reset = false
        elsif scanner.scan(ANSI_REGEXP)
          word << scanner[0]
          ansi_reset = true
        else
          char = scanner.getch
          length += display_width(char)

          if char == separator
            words << word.join
            word = []
          end

          if length <= length_without_trailing
            word << char
          else
            stop = true
          end
        end
      end

      words << word.join if words.empty?

      words << [Strings::ANSI::RESET] if ansi_reset

      words.join + trailing
    end
    module_function :truncate

    # Visible width of a string
    #
    # @return [Integer]
    #
    # @api private
    def display_width(string)
      Unicode::DisplayWidth.of(string)
    end
    module_function :display_width
  end # Truncation
end # Strings
