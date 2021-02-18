# frozen_string_literal: true

RSpec.describe Strings::Truncation, "#configure" do
  it "defaults configuration values" do
    strings = described_class.new

    expect(strings.configuration.length).to eq(30)
    expect(strings.configuration.omission).to eq("…")
    expect(strings.configuration.position).to eq(0)
    expect(strings.configuration.separator).to eq(nil)
  end

  it "configures settings at initialisation" do
    strings = described_class.new(
      length: 25,
      omission: "[...]",
      position: :start,
      separator: /[, ]/
    )

    expect(strings.configuration.length).to eq(25)
    expect(strings.configuration.omission).to eq("[...]")
    expect(strings.configuration.position).to eq(:start)
    expect(strings.configuration.separator).to eq(/[, ]/)

    text = "I try all things, I achieve what I can."

    expect(strings.truncate(text)).to eq("[...]achieve what I can.")
  end

  it "configures settings at runtime" do
    strings = described_class.new

    strings.configure do |config|
      config.length 25
      config.omission "[...]"
      config.position :start
      config.separator(/[, ]/)
    end

    expect(strings.configuration.length).to eq(25)
    expect(strings.configuration.omission).to eq("[...]")
    expect(strings.configuration.position).to eq(:start)
    expect(strings.configuration.separator).to eq(/[, ]/)

    text = "I try all things, I achieve what I can."

    expect(strings.truncate(text)).to eq("[...]achieve what I can.")
  end

  it "overrides configuration on a method call" do
    strings = described_class.new

    strings.configure do |config|
      config.length 25
      config.omission "[...]"
      config.position :start
      config.separator(/[, ]/)
    end

    text = "I try all things, I achieve what I can."

    expect(strings.truncate(text, length: 20, omission: "...",
                                  position: :middle, separator: nil))
      .to eq("I try all...t I can.")
  end
end
