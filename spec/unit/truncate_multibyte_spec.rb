# frozen_string_literal: true

RSpec.describe Strings::Truncation, "truncate multibyte" do
  let(:text) { "ラドクリフ、マラソン五輪代表に1万m出場にも含み" }

  it "truncates text and displays omission" do
    trailing = "…"
    expect(Strings::Truncation.truncate(text, 12)).to eq("ラドクリフ#{trailing}")
  end

  it "estimates total multibyte text width correctly " do
    text = "太丸ゴシック体"
    trailing = "…"
    expect(Strings::Truncation.truncate(text, 8)).to eq("太丸ゴ#{trailing}")
  end

  it "truncates multibyte text with string separator" do
    trailing = "…"
    truncation = Strings::Truncation.truncate(text, 12, separator: "")
    expect(truncation).to eq("ラドクリフ#{trailing}")
  end

  it "truncates multibyte text with regex separator" do
    trailing = "…"
    truncation = Strings::Truncation.truncate(text, 12, separator: /\s/)
    expect(truncation).to eq("ラドクリフ#{trailing}")
  end

  it "truncates multibyte text with custom trailing" do
    trailing = '... (see more)'
    truncation = Strings::Truncation.truncate(text, 20, trailing: trailing)

    expect(truncation).to eq("ラドク#{trailing}")
  end
end
