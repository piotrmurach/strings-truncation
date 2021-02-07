# frozen_string_literal: true

RSpec.describe Strings::Truncation, "truncate multibyte" do
  context "when two characters display length and without space" do
    let(:text) { "ラドクリフ、マラソン五輪代表に1万m出場にも含み" }

    it "doesn't truncate string matching length" do
      text = "こんにちは"
      expect(Strings::Truncation.truncate(text, 10)).to eq(text)
    end

    it "truncates text and displays omission" do
      expect(Strings::Truncation.truncate(text, 12)).to eq("ラドクリフ…")
    end

    it "estimates total multibyte text width correctly " do
      text = "太丸ゴシック体"
      expect(Strings::Truncation.truncate(text, 8)).to eq("太丸ゴ…")
    end

    it "truncates multibyte text with string separator" do
      truncation = Strings::Truncation.truncate(text, 12, separator: "")
      expect(truncation).to eq("ラドクリフ…")
    end

    it "truncates multibyte text with regex separator" do
      truncation = Strings::Truncation.truncate(text, 12, separator: /\s/)
      expect(truncation).to eq("ラドクリフ…")
    end

    it "truncates multibyte text with custom omission" do
      omission = "... (see more)"
      truncation = Strings::Truncation.truncate(text, 20, omission: omission)

      expect(truncation).to eq("ラドク#{omission}")
    end
  end

  context "when one character display length with space" do
    it "doesn't truncate string matching length" do
      text = "Здравствуйте"
      expect(Strings::Truncation.truncate(text, 12)).to eq(text)
    end

    it "truncates 1 character long multibyte with spaces correctly" do
      text = "Я пробую все, добиваюсь того, что могу"
      truncation = Strings::Truncation.truncate(text, 20)

      expect(truncation).to eq("Я пробую все, добив…")
    end

    it "truncates Unicode with separator" do
      text = "Я пробую все, добиваюсь того, что могу"
      truncation = Strings::Truncation.truncate(text, 20, separator: " ")

      expect(truncation).to eq("Я пробую все,…")
    end
  end
end
