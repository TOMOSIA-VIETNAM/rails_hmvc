# frozen_string_literal: true

RSpec.describe RailsHmvc::Generators::InitGenerator, type: :generator do
  destination File.expand_path("../../tmp/init_gen", __dir__)

  before { prepare_destination }

  it "derives app_name from the Rails application" do
    gen = described_class.new([], {}, destination_root: destination_root)
    expect(gen.send(:app_name)).to eq("Dummy")
  end

  it "scaffolds HMVC base files and directories" do
    run_generator
    assert_file "config/rails_hmvc.yml", /type:\s*api/
    assert_file "app/controllers/main_controller.rb"
    assert_file "app/controllers/api_controller.rb"
    assert_file "app/forms/main_form.rb"
    assert_file "app/operations/main_operation.rb"
    assert_file "app/serializers/main_serializer.rb"
    assert_file "app/serializers/error_serializer.rb"
    assert_file "app/controllers/concerns/renderable.rb"
    assert_file "app/controllers/concerns/errorable.rb"
    assert_file "lib/errors/application_error.rb"
    assert_file "lib/errors/resource_error.rb"
  end

  it "removes generated files when destroyed" do
    run_generator
    run_generator [], behavior: :revoke
    assert_no_file "config/rails_hmvc.yml"
    assert_no_file "app/controllers/main_controller.rb"
    assert_no_file "app/controllers/api_controller.rb"
    assert_no_file "app/forms/main_form.rb"
    assert_no_file "app/operations/main_operation.rb"
    assert_no_file "app/serializers/main_serializer.rb"
    assert_no_file "lib/errors/application_error.rb"
    assert_no_file "lib/errors/resource_error.rb"
  end
end
