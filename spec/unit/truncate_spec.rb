# frozen_string_literal: true

RSpec.describe Strings::Truncation, "#truncate" do
  it "doesn't truncate for nil length and returns the original text" do
    text = "It is not down on any map; true places never are."

    expect(Strings::Truncation.truncate(text, nil)).to eq(text)
  end

  it "truncates to length of 0 and returns an empty string" do
    text = "It is not down on any map; true places never are."

    expect(Strings::Truncation.truncate(text, 0)).to eq("")
  end

  it "truncates to length of 1 and returns only the omission character" do
    text = "It is not down on any map; true places never are."

    expect(Strings::Truncation.truncate(text, 1)).to eq("…")
  end

  it "doesn't change text for equal length" do
    text = "It is not down on any map; true places never are."
    truncation = Strings::Truncation.truncate(text, text.length)

    expect(truncation).to eq(text)
  end

  it "doesn't truncate text when length exceeds content" do
    text = "It is not down on any map; true places never are."

    expect(Strings::Truncation.truncate(text, 100)).to eq(text)
  end

  it "goes over default length of 30 characters" do
    text = "It is not down on any map; true places never are."

    expect(Strings::Truncation.truncate(text)).to eq("#{text[0..28]}…")
  end

  it "truncates whole words when separated used" do
    text = "It is not down on any map; true places never are."
    truncation = Strings::Truncation.truncate(text, separator: " ")

    expect(truncation).to eq("It is not down on any map;…")
  end

  it "truncates on word boundary" do
    text = "It is not down on any map; true places never are."
    truncation = Strings::Truncation.truncate(text, 21, separator: /\s/)

    expect(truncation).to eq("It is not down on…")
  end

  it "truncates using :length option" do
    text = "It is not down on any map; true places never are."
    truncation = Strings::Truncation.truncate(text, length: 21)

    expect(truncation).to eq("It is not down on an…")
  end

  it "calls truncate on an instance" do
    text = "It is not down on any map; true places never are."
    strings = Strings::Truncation.new
    truncation = strings.truncate(text, length: 21, separator: " ")

    expect(truncation).to eq("It is not down on…")
  end

  it "truncates with a custom omission" do
    text = "It is not down on any map; true places never are."
    truncation = Strings::Truncation.truncate(text, 40, omission: "[...]")

    expect(truncation).to eq("It is not down on any map; true pla[...]")
  end

  it "truncates with a custom omission and separator" do
    text = "It is not down on any map; true places never are."
    truncation = Strings::Truncation.truncate(text, 40, omission: "[...]",
                                              separator: " ")

    expect(truncation).to eq("It is not down on any map; true[...]")
  end

  it "truncates from an index" do
    text = "It is not down on any map; true places never are."
    truncation = Strings::Truncation.truncate(text, length: 21, position: 10)

    expect(truncation).to eq("…down on any map; tr…")
  end

  it "truncates text from the end" do
    text = "It is not down on any map; true places never are."
    truncation = Strings::Truncation.truncate(text, 20, position: :end)

    expect(truncation).to eq("It is not down on a…")
  end

  it "fails to recognize position parameter" do
    expect {
      Strings::Truncation.truncate("hello", 3, position: :unknown)
    }.to raise_error(Strings::Truncation::Error, "unsupported position: :unknown")
  end

  context "from the start" do
    [
      ["aaaaabbbbb", "", 0],
      ["aaaaabbbbb", "…", 1],
      ["aaaaabbbbb", "…b", 2],
      ["aaaaabbbbb", "…bbbb", 5],
      ["aaaaabbbbb", "…bbbbb", 6],
      ["aaaaabbbbb", "aaaaabbbbb", 10],
      ["aaaaabbbbb", "...bb", 5, { omission: "..." }],
      ["aaaaabbbbb", "...bbb", 6, { omission: "..." }],
      ["aaaaabbbbbc", "…c", 2],
      ["aaaaabbbbbc", "…bbbc", 5],
      ["aaaaabbbbbc", "…bbbbc", 6],
      ["aaaaabbbbbc", "aaaaabbbbbc", 11],
      ["aaaaabbbbbc", "...bc", 5, { omission: "..." }],
      ["aaaaabbbbbc", "...bbc", 6, { omission: "..." }],
      ["aaa bbb ccc", "…", 1, {separator: " "}],
      ["aaa bbb ccc", "…", 2, {separator: " "}],
      ["aaa bbb ccc", "…", 3, {separator: " "}],
      ["aaa bbb ccc", "…ccc", 4, {separator: " "}],
      ["aaa bbb ccc", "…ccc", 5, {separator: " "}],
      ["aaa bbb ccc", "…ccc", 6, {separator: " "}],
      ["aaa bbb ccc", "…ccc", 7, {separator: " "}],
      ["aaa bbb ccc", "…bbb ccc", 8, {separator: " "}],
      ["aaa bbb ccc", "…bbb ccc", 9, {separator: " "}],
      ["aaa bbb ccc", "…bbb ccc", 10, {separator: " "}],
      ["aaa bbb ccc", "aaa bbb ccc", 11, {separator: " "}]
    ].each do |text, truncated, length, options = {}|
      it "truncates #{text.inspect} at #{length} -> #{truncated.inspect}" do
        strings = Strings::Truncation.new
        options.update(position: :start)
        expect(strings.truncate(text, length, **options)).to eq(truncated)
      end
    end

    it "truncates text at the start" do
      text = "It is not down on any map; true places never are."
      truncation = Strings::Truncation.truncate(text, 20, position: :start)

      expect(truncation).to eq("…e places never are.")
    end

    it "truncates text at the start with separator" do
      text = "It is not down on any map; true places never are."
      truncation = Strings::Truncation.truncate(text, 22, position: :start,
                                                separator: " ")

      expect(truncation).to eq("…places never are.")
    end
  end

  context "from the end" do
    [
      ["aaaaabbbbb", "", 0],
      ["aaaaabbbbb", "…", 1],
      ["aaaaabbbbb", "a…", 2],
      ["aaaaabbbbb", "aaaa…", 5],
      ["aaaaabbbbb", "aaaaa…", 6],
      ["aaaaabbbbb", "aaaaabbbbb", 10],
      ["aaaaabbbbb", "aa...", 5, { omission: "..." }],
      ["aaaaabbbbb", "aaa...", 6, { omission: "..." }],
      ["aaaaabbbbbc", "a…", 2],
      ["aaaaabbbbbc", "aaaa…", 5],
      ["aaaaabbbbbc", "aaaaa…", 6],
      ["aaaaabbbbbc", "aaaaabbbbbc", 11],
      ["aaaaabbbbbc", "aa...", 5, { omission: "..." }],
      ["aaaaabbbbbc", "aaa...", 6, { omission: "..." }],
      ["aaa bbb ccc", "…", 1, {separator: " "}],
      ["aaa bbb ccc", "…", 2, {separator: " "}],
      ["aaa bbb ccc", "…", 3, {separator: " "}],
      ["aaa bbb ccc", "aaa…", 4, {separator: " "}],
      ["aaa bbb ccc", "aaa…", 5, {separator: " "}],
      ["aaa bbb ccc", "aaa…", 6, {separator: " "}],
      ["aaa bbb ccc", "aaa…", 7, {separator: " "}],
      ["aaa bbb ccc", "aaa bbb…", 8, {separator: " "}]
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
      ["aaaaabbbbb", "", 0],
      ["aaaaabbbbb", "…", 1],
      ["aaaaabbbbb", "…", 2],
      ["aaaaabbbbb", "…a…", 3],
      ["aaaaabbbbb", "…ab…", 4],
      ["aaaaabbbbb", "…aab…", 5],
      ["aaaaabbbbb", "…aabb…", 6],
      ["aaaaabbbbb", "aaaaabbbbb", 10],
      ["aaaaabbbbb", "...", 5, { omission: "..." }],
      ["aaaaabbbbb", "...a...", 7, { omission: "..." }],
      ["aaaaabbbbb", "...ab...", 8, { omission: "..." }],
      ["aaaaabbbbbc", "…", 2],
      ["aaaaabbbbbc", "…b…", 3],
      ["aaaaabbbbbc", "…ab…", 4],
      ["aaaaabbbbbc", "…abb…", 5],
      ["aaaaabbbbbc", "…aabb…", 6],
      ["aaaaabbbbbc", "aaaaabbbbbc", 11],
      ["aaaaabbbbbc", "...", 5, { omission: "..." }],
      ["aaaaabbbbbc", "...b...", 7, { omission: "..." }],
      ["aaaaabbbbbc", "...ab...", 8, { omission: "..." }],
      ["aaa bbb ccc", "…", 1, { separator: " " }],
      ["aaa bbb ccc", "…", 2, { separator: " " }],
      ["aaa bbb ccc", "…", 3, { separator: " " }],
      ["aaa bbb ccc", "…", 4, { separator: " " }],
      ["aaa bbb ccc", "…bbb…", 5, { separator: " " }],
      ["aaa bbb ccc", "…bbb…", 6, { separator: " " }],
      ["aaa bbb ccc", "…bbb…", 7, { separator: " " }],
      ["aaa bbb ccc", "…bbb ccc", 8, { separator: " " }],
      ["aaa bbb ccc", "..bbb..", 9, { separator: " ", omission: ".." }],
      ["aaa bbb ccc", "..bbb ccc", 10, { separator: " ", omission: ".." }]
    ].each do |text, truncated, length, options = {}|
      it "truncates #{text.inspect} at #{length} -> #{truncated.inspect}" do
        strings = Strings::Truncation.new
        options.update(position: :ends)
        expect(strings.truncate(text, length, **options)).to eq(truncated)
      end
    end

    it "truncates text from both ends with long omission and separator" do
      text = "It is not down on any map; true places never are."
      truncation = Strings::Truncation.truncate(text, 35, position: :ends,
                                                          omission: "...",
                                                          separator: " ")

      expect(truncation).to eq("...down on any map; true places...")
    end
  end

  context "from the middle" do
    [
      ["aaaaabbbbb", "", 0],
      ["aaaaabbbbb", "…", 1],
      ["aaaaabbbbb", "a…", 2],
      ["aaaaabbbbb", "a…b", 3],
      ["aaaaabbbbb", "aa…b", 4],
      ["aaaaabbbbb", "aa…bb", 5],
      ["aaaaabbbbb", "aaa…bb", 6],
      ["aaaaabbbbb", "aaaaabbbbb", 10],
      ["aaaaabbbbb", "aa...bb", 7, { omission: "..." }],
      ["aaaaabbbbb", "aaa...bb", 8, { omission: "..." }],
      ["aaaaabbbbbc", "a…", 2],
      ["aaaaabbbbbc", "a…c", 3],
      ["aaaaabbbbbc", "aa…c", 4],
      ["aaaaabbbbbc", "aa…bc", 5],
      ["aaaaabbbbbc", "aaa…bc", 6],
      ["aaaaabbbbbc", "aaaaabbbbbc", 11],
      ["aaaaabbbbbc", "aa...bc", 7, { omission: "..." }],
      ["aaaaabbbbbc", "aaa...bc", 8, { omission: "..." }],
      ["aaa bbb ccc", "…", 1, {separator: " "}],
      ["aaa bbb ccc", "…", 2, {separator: " "}],
      ["aaa bbb ccc", "…", 3, {separator: " "}],
      ["aaa bbb ccc", "…", 4, {separator: " "}],
      ["aaa bbb ccc", "…", 5, {separator: " "}],
      ["aaa bbb ccc", "aaa…", 6, {separator: " "}],
      ["aaa bbb ccc", "aaa…ccc", 7, {separator: " "}],
      ["aaa bbb ccc", "aaa…ccc", 8, {separator: " "}]
    ].each do |text, truncated, length, options = {}|
      it "truncates #{text.inspect} at #{length} -> #{truncated.inspect}" do
        strings = Strings::Truncation.new
        options.update(position: :middle)
        expect(strings.truncate(text, length, **options)).to eq(truncated)
      end
    end

    it "truncates text from the middle" do
      text = "It is not down on any map; true places never are."
      truncation = Strings::Truncation.truncate(text, 20, position: :middle)

      expect(truncation).to eq("It is not …ever are.")
    end

    it "truncates text from the middle with a long omission" do
      text = "It is not down on any map; true places never are."
      truncation = Strings::Truncation.truncate(text, 35, position: :middle,
                                                omission: "[...]")

      expect(truncation).to eq("It is not down [...]aces never are.")
    end

    it "truncates text from the middle with long omission and separator" do
      text = "It is not down on any map; true places never are."
      truncation = Strings::Truncation.truncate(text, 35, position: :middle,
                                                omission: "[...]",
                                                separator: " ")

      expect(truncation).to eq("It is not down[...]never are.")
    end
  end
end
