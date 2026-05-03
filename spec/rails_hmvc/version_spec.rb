# frozen_string_literal: true

RSpec.describe "RailsHmvc::VERSION" do
  it "is a semver-style string" do
    expect(RailsHmvc::VERSION).to match(/\A\d+\.\d+\.\d+/)
  end
end
