# frozen_string_literal: true

RSpec.describe Errors::APIError do
  it "defaults status and code" do
    err = described_class.new("boom")
    expect(err.status).to eq(500)
    expect(err.code).to eq("api_error")
    expect(err.message).to eq("boom")
  end

  it "accepts overrides" do
    err = described_class.new("nope", status: 503, code: "svc", detail: "d")
    expect(err.status).to eq(503)
    expect(err.code).to eq("svc")
    expect(err.detail).to eq("d")
  end
end
