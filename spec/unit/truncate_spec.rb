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

    expect(Strings::Truncation.truncate(text, 1))
      .to eq(Strings::Truncation::DEFAULT_OMISSION)
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
    omission = "…"
    truncation = Strings::Truncation.truncate(text, separator: " ")

    expect(truncation).to eq("It is not down on any map;#{omission}")
  end

  it "truncates on word boundary" do
    text = "It is not down on any map; true places never are."
    truncation = Strings::Truncation.truncate(text, 21, separator: " ")

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
    truncation = Strings::Truncation.truncate(text, 40,
                                              omission: "...(continued)")

    expect(truncation).to eq("It is not down on any map;...(continued)")
  end
end
