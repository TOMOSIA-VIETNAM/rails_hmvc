# frozen_string_literal: true

RSpec.describe RailsHmvc do
  it "defines Error base class" do
    expect(RailsHmvc::Error.superclass).to eq(StandardError)
  end
end
