# frozen_string_literal: true

module Strings
  class Truncation
    # A configuration object used by a Strings::Truncation instance
    #
    # @api private
    class Configuration
      DEFAULT_LENGTH = 30

      DEFAULT_OMISSION = "…"

      DEFAULT_POSITION = 0

      # Create a configuration
      #
      # @api public
      def initialize(length: DEFAULT_LENGTH, omission: DEFAULT_OMISSION,
                     position: DEFAULT_POSITION, separator: nil)
        @length = length
        @omission = omission
        @position = position
        @separator = separator
      end

      # Update current configuration
      #
      # @api public
      def update(length: nil, omission: nil, position: nil, separator: nil)
        @length = length if length
        @omission = omission if omission
        @position = position if position
        @separator = separator if separator
      end

      # The maximum length to truncate to
      #
      # @example
      #   strings = Strings::Truncation.new
      #
      #   strings.configure do |config|
      #     config.length 40
      #   end
      #
      # @param [Integer] number
      #
      # @api public
      def length(number = (not_set = true))
        if not_set
          @length
        else
          @length = number
        end
      end

      # The string to denote omitted content
      #
      # @example
      #   strings = Strings::Truncation.new
      #
      #   strings.configure do |config|
      #     config.omission "..."
      #   end
      #
      # @param [String] string
      #
      # @api public
      def omission(string = (not_set = true))
        if not_set
          @omission
        else
          @omission = string
        end
      end

      # The position of the omission within the string
      #
      # @example
      #   strings = Strings::Truncation.new
      #
      #   strings.configure do |config|
      #     config.position :start
      #   end
      #
      #
      # @param [Symbol] position
      #   the position out of :start, :middle or :end
      #
      # @api public
      def position(position = (not_set = true))
        if not_set
          @position
        else
          @position = position
        end
      end

      # The separator to break the characters into words
      #
      # @example
      #   strings = Strings::Truncation.new
      #
      #   strings.configure do |config|
      #     config.separator /[, ]/
      #   end
      #
      # @param [String|Regexp] separator
      #
      # @api public
      def separator(separator = (not_set = true))
        if not_set
          @separator
        else
          @separator = separator
        end
      end
    end # Configruation
  end # Truncation
end # Strings
