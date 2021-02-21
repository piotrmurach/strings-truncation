# frozen_string_literal: true

RSpec.describe Strings::Truncation, "truncate multibyte" do
  context "when two characters display length and without space" do
    let(:text) { "ラドクリフ、マラソン五輪代表に1万出場にも含み" }

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
      truncation = Strings::Truncation.truncate(text, 12, separator: "、")
      expect(truncation).to eq("ラドクリフ…")
    end

    it "truncates multibyte text with regex separator" do
      truncation = Strings::Truncation.truncate(text, 12, separator: /、/)
      expect(truncation).to eq("ラドクリフ…")
    end

    it "truncates multibyte text with custom omission" do
      omission = "... (see more)"
      truncation = Strings::Truncation.truncate(text, 20, omission: omission)

      expect(truncation).to eq("ラドク#{omission}")
    end

    context "from the start" do
      [
        ["ありがとう", "", 0],
        ["ありがとう", "…", 1],
        ["ありがとう", "…", 2],
        ["ありがとう", "…とう", 5],
        ["ありがとう", "…とう", 6],
        ["ありがとう", "ありがとう", 10],
        ["ありがとう", "...とう", 7, { omission: "..." }],
        ["ありがとう", "...とう", 8, { omission: "..." }],
        ["ありがとう!", "…!", 2],
        ["ありがとう!", "…う!", 5],
        ["ありがとう!", "…とう!", 6],
        ["ありがとう!", "ありがとう!", 11],
        ["ありがとう!", "...う!", 7, { omission: "..." }],
        ["ありがとう!", "...とう!", 8, { omission: "..." }],
        ["あり がと う", "…", 1, {separator: " "}],
        ["あり がと う", "…", 2, {separator: " "}],
        ["あり がと う", "…う", 3, {separator: " "}],
        ["あり がと う", "…う", 6, {separator: " "}],
        ["あり がと う", "…がと う", 8, {separator: " "}],
        ["あり がと う", "…がと う", 9, {separator: " "}],
        ["あり がと う", "…がと う", 10, {separator: " "}],
        ["あり がと う", "…がと う", 11, {separator: " "}],
        ["あり がと う", "あり がと う", 12, {separator: " "}],
      ].each do |text, truncated, length, options = {}|
        it "truncates #{text.inspect} at #{length} -> #{truncated.inspect}" do
          strings = Strings::Truncation.new
          options.update(position: :start)
          expect(strings.truncate(text, length, **options)).to eq(truncated)
        end
      end
    end

    context "from the end" do
      [
        ["ありがとう", "", 0],
        ["ありがとう", "…", 1],
        ["ありがとう", "…", 2],
        ["ありがとう", "あり…", 5],
        ["ありがとう", "あり…", 6],
        ["ありがとう", "ありがとう", 10],
        ["ありがとう", "あり...", 7, { omission: "..." }],
        ["ありがとう", "あり...", 8, { omission: "..." }],
        ["*ありがとう", "*…", 2],
        ["*ありがとう", "*あ…", 5],
        ["*ありがとう", "*あり…", 6],
        ["*ありがとう", "*ありがとう", 11],
        ["*ありがとう", "*あ...", 7, { omission: "..." }],
        ["*ありがとう", "*あり...", 8, { omission: "..." }],
        ["あり がと う", "…", 1, {separator: " "}],
        ["あり がと う", "…", 2, {separator: " "}],
        ["あり がと う", "…", 3, {separator: " "}],
        ["あり がと う", "あり…", 6, {separator: " "}],
        ["あり がと う", "あり…", 8, {separator: " "}],
      ].each do |text, truncated, length, options = {}|
        it "truncates #{text.inspect} at #{length} -> #{truncated.inspect}" do
          strings = Strings::Truncation.new
          options.update(position: :end)
          expect(strings.truncate(text, length, **options)).to eq(truncated)
        end
      end
    end

    context "from both ends" do
      [
        ["ありがとう", "", 0],
        ["ありがとう", "…", 1],
        ["ありがとう", "…", 2],
        ["ありがとう", "…が…", 5],
        ["ありがとう", "…がと…", 6],
        ["ありがとう", "…りが…", 7],
        ["ありがとう", "…りがと…", 8],
        ["ありがとう", "…りがとう", 9],
        ["ありがとう", "ありがとう", 10],
        ["ありがとう", "...", 7, { omission: "..." }],
        ["ありがとう", "...が...", 8, { omission: "..." }],
        ["ありがとう!", "…", 2],
        ["ありがとう!", "…が…", 5],
        ["ありがとう!", "…がと…", 6],
        ["ありがとう!", "…りがと…", 8],
        ["ありがとう!", "…りがとう!", 10],
        ["ありがとう!", "ありがとう!", 11],
        ["ありがとう!", "..が..", 7, { omission: ".." }],
        ["ありがとう!", "..がと..", 8, { omission: ".." }],
        ["あり がと う", "…", 1, { separator: " " }],
        ["あり がと う", "…", 2, { separator: " " }],
        ["あり がと う", "…がと…", 6, { separator: " " }],
        ["あり がと う", "…がと …", 7, { separator: " " }],
        ["あり がと う", "…がと う", 8, { separator: " " }],
        ["あり がと う", "…がと う", 9, { separator: " " }]
      ].each do |text, truncated, length, options = {}|
        it "truncates #{text.inspect} at #{length} -> #{truncated.inspect}" do
          strings = Strings::Truncation.new
          options.update(position: :ends)
          expect(strings.truncate(text, length, **options)).to eq(truncated)
        end
      end
    end

    context "from the middle" do
      [
        ["ありがとう", "", 0],
        ["ありがとう", "…", 1],
        ["ありがとう", "…", 2],
        ["ありがとう", "あ…う", 5],
        ["ありがとう", "あ…う", 6],
        ["ありがとう", "ありがとう", 10],
        ["ありがとう", "あ...う", 7, { omission: "..." }],
        ["ありがとう", "あ...う", 8, { omission: "..." }],
        ["ありがとう!", "…", 2],
        ["ありがとう!", "あ…!", 5],
        ["ありがとう!", "あ…!", 6],
        ["ありがとう!", "ありがとう!", 11],
        ["ありがとう!", "あ...!", 7, { omission: "..." }],
        ["ありがとう!", "あ...!", 8, { omission: "..." }],
        ["あり がと う", "…", 1, {separator: " "}],
        ["あり がと う", "…", 2, {separator: " "}],
        ["あり がと う", "…", 3, {separator: " "}],
        ["あり がと う", "…う", 6, {separator: " "}],
        ["あり がと う", "あり…う", 8, {separator: " "}],
      ].each do |text, truncated, length, options = {}|
        it "truncates #{text.inspect} at #{length} -> #{truncated.inspect}" do
          strings = Strings::Truncation.new
          options.update(position: :middle)
          expect(strings.truncate(text, length, **options)).to eq(truncated)
        end
      end
    end
  end

  context "when one character display length with space" do
    let(:text) { "Я пробую все, добиваюсь того, что могу" }

    it "doesn't truncate string matching length" do
      text = "Здравствуйте"
      expect(Strings::Truncation.truncate(text, 12)).to eq(text)
    end

    it "truncates 1 character long multibyte with spaces correctly" do
      truncation = Strings::Truncation.truncate(text, 20)

      expect(truncation).to eq("Я пробую все, добив…")
    end

    it "truncates Unicode with separator" do
      truncation = Strings::Truncation.truncate(text, 20, separator: " ")

      expect(truncation).to eq("Я пробую все,…")
    end

    context "from the start" do
      [
        ["Здравствуйте", "", 0],
        ["Здравствуйте", "…", 1],
        ["Здравствуйте", "…е", 2],
        ["Здравствуйте", "…уйте", 5],
        ["Здравствуйте", "…вуйте", 6],
        ["Здравствуйте", "Здравствуйте", 12],
        ["Здравствуйте", "...уйте", 7, { omission: "..." }],
        ["Здравствуйте", "...вуйте", 8, { omission: "..." }],
        ["Здравствуйте!", "…!", 2],
        ["Здравствуйте!", "…йте!", 5],
        ["Здравствуйте!", "…уйте!", 6],
        ["Здравствуйте!", "Здравствуйте!", 13],
        ["Здравствуйте!", "...йте!", 7, { omission: "..." }],
        ["Здравствуйте!", "...уйте!", 8, { omission: "..." }],
      ].each do |text, truncated, length, options = {}|
        it "truncates #{text.inspect} at #{length} -> #{truncated.inspect}" do
          strings = Strings::Truncation.new
          options.update(position: :start)
          expect(strings.truncate(text, length, **options)).to eq(truncated)
        end
      end
    end

    context "from the middle" do
      [
        ["Здравствуйте", "", 0],
        ["Здравствуйте", "…", 1],
        ["Здравствуйте", "З…", 2],
        ["Здравствуйте", "Зд…те", 5],
        ["Здравствуйте", "Здр…те", 6],
        ["Здравствуйте", "Здравствуйте", 12],
        ["Здравствуйте", "Зд...те", 7, { omission: "..." }],
        ["Здравствуйте", "Здр...те", 8, { omission: "..." }],
        ["Здравствуйте!", "З…", 2],
        ["Здравствуйте!", "Зд…е!", 5],
        ["Здравствуйте!", "Здр…е!", 6],
        ["Здравствуйте!", "Здравствуйте!", 13],
        ["Здравствуйте!", "Зд...е!", 7, { omission: "..." }],
        ["Здравствуйте!", "Здр...е!", 8, { omission: "..." }],
      ].each do |text, truncated, length, options = {}|
        it "truncates #{text.inspect} at #{length} -> #{truncated.inspect}" do
          strings = Strings::Truncation.new
          options.update(position: :middle)
          expect(strings.truncate(text, length, **options)).to eq(truncated)
        end
      end
    end
  end
end
