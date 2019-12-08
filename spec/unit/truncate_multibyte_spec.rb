# frozen_string_literal: true

RSpec.describe Strings::Truncation, "truncate multibyte" do
  let(:text) { "ラドクリフ、マラソン五輪代表に1万m出場にも含み" }

  it "truncates text and displays omission" do
    omission = "…"
    expect(Strings::Truncation.truncate(text, 12)).to eq("ラドクリフ#{omission}")
  end

  it "estimates total multibyte text width correctly " do
    text = "太丸ゴシック体"
    omission = "…"
    expect(Strings::Truncation.truncate(text, 8)).to eq("太丸ゴ#{omission}")
  end

  it "truncates multibyte text with string separator" do
    omission = "…"
    truncation = Strings::Truncation.truncate(text, 12, separator: "")
    expect(truncation).to eq("ラドクリフ#{omission}")
  end

  it "truncates multibyte text with regex separator" do
    omission = "…"
    truncation = Strings::Truncation.truncate(text, 12, separator: /\s/)
    expect(truncation).to eq("ラドクリフ#{omission}")
  end

  it "truncates multibyte text with custom omission" do
    omission = '... (see more)'
    truncation = Strings::Truncation.truncate(text, 20, omission: omission)

    expect(truncation).to eq("ラドク#{omission}")
  end
end
