# frozen_string_literal: true

require "open3"

# rubocop:disable RSpec/DescribeClass
RSpec.describe "hmvc CLI binary" do
  let(:binary) { File.expand_path("../exe/hmvc", __dir__) }

  it "binary exists and is executable" do
    expect(File.exist?(binary)).to be true
    expect(File.executable?(binary)).to be true
  end

  describe "hmvc version" do
    it "prints the gem version" do
      stdout, _stderr, status = Open3.capture3(binary, "version")
      expect(status).to be_success
      expect(stdout.strip).to eq(RailsHmvc::VERSION)
    end
  end

  describe "hmvc --version" do
    it "prints the gem version" do
      stdout, _stderr, status = Open3.capture3(binary, "--version")
      expect(status).to be_success
      expect(stdout.strip).to eq(RailsHmvc::VERSION)
    end
  end

  describe "hmvc --help" do
    it "prints usage information" do
      stdout, _stderr, status = Open3.capture3(binary, "--help")
      expect(status).to be_success
      expect(stdout).to include("init")
      expect(stdout).to include("version")
    end
  end

  describe "hmvc d" do
    it "requires a generator name" do
      _stdout, stderr, status = Open3.capture3(binary, "d")
      expect(status).not_to be_success
      expect(stderr).to include("generator name required")
    end
  end

  describe "hmvc destroy" do
    it "requires a generator name" do
      _stdout, stderr, status = Open3.capture3(binary, "destroy")
      expect(status).not_to be_success
      expect(stderr).to include("generator name required")
    end
  end

  describe "hmvc unknown" do
    it "exits with a non-zero status and prints an error" do
      _stdout, stderr, status = Open3.capture3(binary, "unknown_command_xyz")
      expect(status).not_to be_success
      expect(stderr).to include("unknown_command_xyz")
    end
  end
end
# rubocop:enable RSpec/DescribeClass
