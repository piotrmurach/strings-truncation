# frozen_string_literal: true

require "strings/truncation/extensions"

using Strings::Truncation::Extensions

RSpec.describe Strings::Truncation::Extensions do
  it "truncates a string to a given length" do
    expect("I try all things, I achieve what I can.".truncate(15))
      .to eq("I try all thin…")
  end

  it "truncates a string based on separator" do
    expect("I try all things, I achieve what I can.".truncate(15, separator: " "))
      .to eq("I try all…")
  end
end
