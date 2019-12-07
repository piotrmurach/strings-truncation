# frozen_string_literal: true

RSpec.describe Strings::Truncation, "truncate ansi" do
  it "truncates string with ANSI characters within boundary" do
    text = "I try \e[34mall things\e[0m, I achieve what I can"
    truncation = Strings::Truncation.truncate(text, 18)
    expect(truncation).to eq("I try \e[34mall things\e[0m,…")
  end

  it "adds ANSI reset for shorter string" do
    text = "I try \e[34mall things\e[0m, I achieve what I can"
    truncation = Strings::Truncation.truncate(text, 10)
    expect(truncation).to eq("I try \e[34mall\e[0m…")
  end
end
