# frozen_string_literal: true

RSpec.describe Errors::BaseError do
  describe "#initialize and #to_hash" do
    it "stores attributes and compacts nils in to_hash" do
      err = described_class.new("msg", status: 400, code: "x", detail: nil)
      expect(err.status).to eq(400)
      expect(err.code).to eq("x")
      expect(err.detail).to be_nil
      expect(err.message).to eq("msg")
      expect(err.to_hash).to eq({ status: 400, code: "x", message: "msg" })
    end

    it "allows all keyword fields nil" do
      err = described_class.new("only")
      expect(err.to_hash).to eq({ message: "only" })
    end
  end
end
