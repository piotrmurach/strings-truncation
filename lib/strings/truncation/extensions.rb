# frozen_string_literal: true

require_relative "../truncation"

module Strings
  class Truncation
    module Extensions
      refine String do
        def truncate(*args, **options)
          Strings::Truncation.truncate(self, *args, **options)
        end
      end
    end # Extensions
  end # Truncation
end # Strings
