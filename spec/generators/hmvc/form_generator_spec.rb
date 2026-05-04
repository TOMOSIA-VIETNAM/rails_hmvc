# frozen_string_literal: true

RSpec.describe RailsHmvc::Generators::FormGenerator, type: :generator do
  destination File.expand_path("../../tmp/form_gen", __dir__)

  before do
    prepare_destination
    RailsHmvcGeneratorConfig.write_config(destination_root, RailsHmvcGeneratorConfig.api_yaml)
  end

  it "writes the form with default attribute when none given" do
    run_generator %w[v1/posts/create]
    assert_file "app/forms/v1/posts/create_form.rb", /attribute :name/
  end

  it "writes typed attributes when --attributes is set" do
    run_generator %w[v1/posts/update --attributes=title:string,body:text]
    assert_file "app/forms/v1/posts/update_form.rb", /attribute :title, :string/
    assert_file "app/forms/v1/posts/update_form.rb", /attribute :body, :text/
  end

  it "writes one form per action for --actions" do
    run_generator %w[v1/comments --actions=create,update --parent=MainForm]
    assert_file "app/forms/v1/comments/create_form.rb"
    assert_file "app/forms/v1/comments/update_form.rb"
  end

  it "emits attribute without type when type omitted" do
    run_generator %w[v1/likes/index --attributes=flag]
    assert_file "app/forms/v1/likes/index_form.rb", /attribute :flag$/
  end

  it "computes form_path with current_action set" do
    gen = described_class.new(%w[v1/posts], {}, { destination_root: destination_root })
    gen.instance_variable_set(:@current_action, "create")
    expect(gen.send(:form_path)).to eq("posts/create_form")
  end

  it "removes generated files when destroyed" do
    run_generator %w[v1/posts/create]
    run_generator %w[v1/posts/create], behavior: :revoke
    assert_no_file "app/forms/v1/posts/create_form.rb"
  end

  it "removes multiple form files when destroyed with --actions" do
    run_generator %w[v1/comments --actions=create,update]
    run_generator %w[v1/comments --actions=create,update], behavior: :revoke
    assert_no_file "app/forms/v1/comments/create_form.rb"
    assert_no_file "app/forms/v1/comments/update_form.rb"
  end
end
