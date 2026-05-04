# frozen_string_literal: true

RSpec.describe RailsHmvc::Generators::OperationGenerator, type: :generator do
  destination File.expand_path("../../tmp/operation_gen", __dir__)

  before do
    prepare_destination
    RailsHmvcGeneratorConfig.write_config(destination_root, RailsHmvcGeneratorConfig.api_yaml)
  end

  it "writes one operation class for a single name" do
    run_generator %w[v1/posts/create]
    assert_file "app/operations/v1/posts/create_operation.rb", /CreateOperation/
  end

  it "writes one file per action when --actions is given" do
    run_generator %w[v1/posts --actions=index,create --parent=MainOperation --steps=foo,bar]
    assert_file "app/operations/v1/posts/index_operation.rb", /IndexOperation/
    assert_file "app/operations/v1/posts/create_operation.rb", /step_foo/
  end

  it "does not double-prefix step_ when steps already prefixed" do
    run_generator %w[v1/tags/show --steps=step_run,step_done]
    assert_file "app/operations/v1/tags/show_operation.rb", /def step_run/
    assert_file "app/operations/v1/tags/show_operation.rb", /def step_done/
  end

  it "computes operation_path with current_action set" do
    gen = described_class.new(%w[v1/posts], {}, { destination_root: destination_root })
    gen.instance_variable_set(:@current_action, "create")
    expect(gen.send(:operation_path)).to eq("posts/create_operation")
  end

  it "removes generated files when destroyed" do
    run_generator %w[v1/posts/create]
    run_generator %w[v1/posts/create], behavior: :revoke
    assert_no_file "app/operations/v1/posts/create_operation.rb"
  end

  it "removes multiple operation files when destroyed with --actions" do
    run_generator %w[v1/orders --actions=approve,reject]
    run_generator %w[v1/orders --actions=approve,reject], behavior: :revoke
    assert_no_file "app/operations/v1/orders/approve_operation.rb"
    assert_no_file "app/operations/v1/orders/reject_operation.rb"
  end
end
