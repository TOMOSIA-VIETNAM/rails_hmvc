# frozen_string_literal: true

RSpec.describe Errors::ResourceError do
  it "wraps a string message and sets errors array" do
    err = described_class.new(resource: :user, message: "bad")
    expect(err.resource).to eq(:user)
    expect(err.errors).to eq(["bad"])
    expect(err.to_hash[:resource]).to eq(:user)
    expect(err.to_hash[:message]).to eq("bad")
  end

  it "normalizes array message" do
    err = described_class.new(resource: "Post", message: %w[a b])
    expect(err.errors).to eq(%w[a b])
  end

  it "uses default message when message is nil" do
    err = described_class.new(resource: :item, message: nil)
    expect(err.message).to include("item")
  end
end
