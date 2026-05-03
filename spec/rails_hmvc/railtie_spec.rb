# frozen_string_literal: true

RSpec.describe RailsHmvc::Railtie do
  it "is a Rails::Railtie" do
    expect(described_class.superclass).to eq(Rails::Railtie)
  end

  it "registers HMVC generators for invocation" do
    expect do
      Rails::Generators.invoke("rails_hmvc:init", [], destination_root: Dir.mktmpdir,
                                                      shell: Thor::Shell::Basic.new)
    end.not_to raise_error
  end
end
