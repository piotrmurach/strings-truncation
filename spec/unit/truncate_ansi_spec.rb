# frozen_string_literal: true

RSpec.describe Strings::Truncation, "truncates ansi" do
  it "doesn't truncate string matching length" do
    text = "\e[32mHello\e[0m"
    expect(Strings::Truncation.truncate(text, 5)).to eq(text)
  end

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

  it "correctly estimates width of strings with ANSI codes " do
    text = "I try \e[34mall things\e[0m, I achieve"

    expect(Strings::Truncation.truncate(text))
      .to eq("I try \e[34mall things\e[0m, I achieve")
  end

  context "from the start" do
    [
      ["\e[34maaaaabbbbb\e[0m", "", 0],
      ["\e[34maaaaabbbbb\e[0m", "…", 1],
      ["\e[34maaaaabbbbb\e[0m", "…\e[34mb\e[0m", 2],
      ["\e[34maaaaabbbbb\e[0m", "…\e[34mbbbb\e[0m", 5],
      ["\e[34maaaaabbbbb\e[0m", "…\e[34mbbbbb\e[0m", 6],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maaaaabbbbb\e[0m", 10],
      ["\e[34maaaaabbbbb\e[0m", "...\e[34mbb\e[0m", 5, { omission: "..." }],
      ["\e[34maaaaabbbbb\e[0m", "...\e[34mbbb\e[0m", 6, { omission: "..." }],
      ["\e[34maaaaabbbbbc\e[0m", "…\e[34mc\e[0m", 2],
      ["\e[34maaaaabbbbbc\e[0m", "…\e[34mbbbc\e[0m", 5],
      ["\e[34maaaaabbbbbc\e[0m", "…\e[34mbbbbc\e[0m", 6],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maaaaabbbbbc\e[0m", 11],
      ["\e[34maaaaabbbbbc\e[0m", "...\e[34mbc\e[0m", 5, { omission: "..." }],
      ["\e[34maaaaabbbbbc\e[0m", "...\e[34mbbc\e[0m", 6, { omission: "..." }],
      ["\e[34maaa bbb ccc\e[0m", "…", 1, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34m\e[0m", 2, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34m\e[0m", 3, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34mccc\e[0m", 4, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34mccc\e[0m", 5, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34mccc\e[0m", 6, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34mccc\e[0m", 7, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34mbbb ccc\e[0m", 8, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34mbbb ccc\e[0m", 9, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34mbbb ccc\e[0m", 10, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "\e[34maaa bbb ccc\e[0m", 11, {separator: " "}]
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
      ["\e[34maaaaabbbbb\e[0m", "", 0],
      ["\e[34maaaaabbbbb\e[0m", "\e[34m\e[0m…", 1],
      ["\e[34maaaaabbbbb\e[0m", "\e[34ma\e[0m…", 2],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maaaa\e[0m…", 5],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maaaaa\e[0m…", 6],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maaaaabbbbb\e[0m", 10],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maa\e[0m...", 5, { omission: "..." }],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maaa\e[0m...", 6, { omission: "..." }],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34ma\e[0m…", 2],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maaaa\e[0m…", 5],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maaaaa\e[0m…", 6],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maaaaabbbbbc\e[0m", 11],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maa\e[0m...", 5, { omission: "..." }],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maaa\e[0m...", 6, { omission: "..." }],
      ["\e[34maaa bbb ccc\e[0m", "\e[34m\e[0m…", 1, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "\e[34m\e[0m…", 2, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "\e[34m\e[0m…", 3, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "\e[34maaa\e[0m…", 4, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "\e[34maaa\e[0m…", 5, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "\e[34maaa\e[0m…", 6, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "\e[34maaa\e[0m…", 7, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "\e[34maaa bbb\e[0m…", 8, { separator: " " }]
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
      ["\e[34maaaaabbbbb\e[0m", "", 0],
      ["\e[34maaaaabbbbb\e[0m", "…", 1],
      ["\e[34maaaaabbbbb\e[0m", "…", 2],
      ["\e[34maaaaabbbbb\e[0m", "…\e[34ma\e[0m…", 3],
      ["\e[34maaaaabbbbb\e[0m", "…\e[34mab\e[0m…", 4],
      ["\e[34maaaaabbbbb\e[0m", "…\e[34maab\e[0m…", 5],
      ["\e[34maaaaabbbbb\e[0m", "…\e[34maabb\e[0m…", 6],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maaaaabbbbb\e[0m", 10],
      ["\e[34maaaaabbbbb\e[0m", "...", 5, { omission: "..." }],
      ["\e[34maaaaabbbbb\e[0m", "...\e[34ma\e[0m...", 7, { omission: "..." }],
      ["\e[34maaaaabbbbb\e[0m", "...\e[34mab\e[0m...", 8, { omission: "..." }],
      ["\e[34maaaaabbbbbc\e[0m", "…", 2],
      ["\e[34maaaaabbbbbc\e[0m", "…\e[34mabb\e[0m…", 5],
      ["\e[34maaaaabbbbbc\e[0m", "…\e[34maabb\e[0m…", 6],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maaaaabbbbbc\e[0m", 11],
      ["\e[34maaaaabbbbbc\e[0m", "...", 5, { omission: "..." }],
      ["\e[34maaaaabbbbbc\e[0m", "...\e[34mb\e[0m...", 7, { omission: "..." }],
      ["\e[34maaaaabbbbbc\e[0m", "...\e[34mab\e[0m...", 8, { omission: "..." }],
      ["\e[34maaa bbb ccc\e[0m", "…", 1, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "…", 2, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34m\e[0m…", 3, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34m\e[0m…", 4, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34mbbb\e[0m…", 5, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34mbbb\e[0m…", 6, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34mbbb\e[0m…", 7, { separator: " " }],
      ["\e[34maaa bbb ccc\e[0m", "…\e[34mbbb ccc\e[0m", 10, { separator: " " }]
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
      ["\e[34maaaaabbbbb\e[0m", "", 0],
      ["\e[34maaaaabbbbb\e[0m", "…", 1],
      ["\e[34maaaaabbbbb\e[0m", "\e[34ma\e[0m…", 2],
      ["\e[34maaaaabbbbb\e[0m", "\e[34ma\e[0m…\e[34mb\e[0m", 3],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maa\e[0m…\e[34mb\e[0m", 4],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maa\e[0m…\e[34mbb\e[0m", 5],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maaa\e[0m…\e[34mbb\e[0m", 6],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maaaaabbbbb\e[0m", 10],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maa\e[0m...\e[34mbb\e[0m", 7,
       { omission: "..." }],
      ["\e[34maaaaabbbbb\e[0m", "\e[34maaa\e[0m...\e[34mbb\e[0m", 8,
       { omission: "..." }],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34ma\e[0m…", 2],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34ma\e[0m…\e[34mc\e[0m", 3],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maa\e[0m…\e[34mc\e[0m", 4],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maa\e[0m…\e[34mbc\e[0m", 5],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maaa\e[0m…\e[34mbc\e[0m", 6],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maaaaabbbbbc\e[0m", 11],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maa\e[0m...\e[34mbc\e[0m", 7,
       { omission: "..." }],
      ["\e[34maaaaabbbbbc\e[0m", "\e[34maaa\e[0m...\e[34mbc\e[0m", 8,
       { omission: "..." }],
      ["\e[34maaa bbb ccc\e[0m", "…", 1, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "\e[34m\e[0m…", 2, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "\e[34m\e[0m…\e[34m\e[0m", 3, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "\e[34m\e[0m…\e[34m\e[0m", 4, {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "\e[34m\e[0m…\e[34m\e[0m", 5,
       {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "\e[34maaa\e[0m…\e[34m\e[0m", 6,
       {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "\e[34maaa\e[0m…\e[34mccc\e[0m", 7,
       {separator: " "}],
      ["\e[34maaa bbb ccc\e[0m", "\e[34maaa\e[0m…\e[34mccc\e[0m", 8,
       {separator: " "}]
    ].each do |text, truncated, length, options = {}|
      it "truncates #{text.inspect} at #{length} -> #{truncated.inspect}" do
        strings = Strings::Truncation.new
        options.update(position: :middle)
        expect(strings.truncate(text, length, **options)).to eq(truncated)
      end
    end

    it "truncates text with ANSI in the middle" do
      text = "aaaaabbbbb\e[34mccccc\e[0mddddd"
      truncation = Strings::Truncation.truncate(text, 14, position: :middle)

      expect(truncation).to eq("aaaaabb…\e[34mc\e[0mddddd")
    end

    it "truncates text from the middle" do
      text = "\e[34mIt is not down on any map; true places never are.\e[0m"
      truncation = Strings::Truncation.truncate(text, 20, position: :middle)

      expect(truncation).to eq("\e[34mIt is not \e[0m…\e[34mever are.\e[0m")
    end

    it "truncates text from the middle with a long omission" do
      text = "\e[34mIt is not down on any map; true places never are.\e[0m"
      truncation = Strings::Truncation.truncate(text, 35, position: :middle,
                                                omission: "[...]")

      expect(truncation)
        .to eq("\e[34mIt is not down \e[0m[...]\e[34maces never are.\e[0m")
    end
  end
end
