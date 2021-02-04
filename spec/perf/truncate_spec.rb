# frozen_string_literal: true

require "rspec-benchmark"
require "active_support/core_ext/string/filters"

RSpec.describe Strings::Truncation do
  include RSpec::Benchmark::Matchers

  it "pluralizes nouns as fast as ActiveSupport" do
    text = "It is not down on any map; true places never are."
    expect {
      Strings::Truncation.truncate(text, 20)
    }.to perform_slower_than {
      text.truncate(20)
    }.at_most(150).times
  end

  it "allocates no more than 107 objects" do
    text = "It is not down on any map; true places never are."
    expect {
      Strings::Truncation.truncate(text, 20)
    }.to perform_allocation(107)
  end
end
