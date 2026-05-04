# frozen_string_literal: true

RSpec.describe RailsHmvc::Generators::ControllerGenerator, type: :generator do
  destination File.expand_path("../../tmp/controller_gen", __dir__)

  before do
    prepare_destination
    RailsHmvcGeneratorConfig.write_config(destination_root, RailsHmvcGeneratorConfig.api_yaml)
  end

  it "generates api controller, operations, and forms" do
    run_generator %w[v1/posts]
    assert_file "app/controllers/v1/posts_controller.rb", /render_collection/
    assert_file "app/operations/v1/posts/index_operation.rb"
    assert_file "app/forms/v1/posts/create_form.rb"
  end

  it "generates web-style controller when type is web" do
    RailsHmvcGeneratorConfig.write_config(destination_root, RailsHmvcGeneratorConfig.web_yaml)
    run_generator %w[v1/articles --type=web]
    assert_file "app/controllers/v1/articles_controller.rb", /render :index/
    assert_file "app/controllers/v1/articles_controller.rb", /redirect_to/
  end

  it "skips controller, operations, and forms when flags set" do
    run_generator %w[v1/items --skip-controller --skip-operation --skip-form]
    assert_no_file "app/controllers/v1/items_controller.rb"
    assert_no_file "app/operations/v1/items/index_operation.rb"
    assert_no_file "app/forms/v1/items/create_form.rb"
  end

  it "uses head :no_content for web destroy when operations are skipped" do
    RailsHmvcGeneratorConfig.write_config(destination_root, RailsHmvcGeneratorConfig.web_yaml)
    run_generator %w[v1/pages --type=web --skip-operation]
    assert_file "app/controllers/v1/pages_controller.rb", /def destroy/
    assert_file "app/controllers/v1/pages_controller.rb", /head :no_content/m
  end

  it "respects form skip_actions from yaml for web" do
    RailsHmvcGeneratorConfig.write_config(destination_root, RailsHmvcGeneratorConfig.web_yaml)
    run_generator %w[v1/widgets --type=web]
    assert_no_file "app/forms/v1/widgets/destroy_form.rb"
    assert_file "app/forms/v1/widgets/create_form.rb"
  end

  it "uses actions array from YAML without splitting" do
    cfg = RailsHmvcGeneratorConfig.api_yaml.dup
    cfg["api"] = cfg["api"].dup
    cfg["api"]["controllers"] = { "parent" => "MainController", "actions" => %w[index show] }
    RailsHmvcGeneratorConfig.write_config(destination_root, cfg)
    run_generator %w[v1/orders]
    assert_file "app/controllers/v1/orders_controller.rb", /def show/
    body = File.read(File.join(destination_root, "app/controllers/v1/orders_controller.rb"))
    expect(body).not_to include("def destroy")
  end

  it "falls back to render :action for unknown web actions (render_web_response)" do
    RailsHmvcGeneratorConfig.write_config(destination_root, RailsHmvcGeneratorConfig.web_yaml)
    gen = described_class.new(%w[v1/feeds], { type: "web" }, { destination_root: destination_root })
    expect(gen.send(:render_web_response, "publish")).to eq("render :publish")
  end

  it "removes generated files when destroyed" do
    run_generator %w[v1/posts]
    run_generator %w[v1/posts], behavior: :revoke
    assert_no_file "app/controllers/v1/posts_controller.rb"
    assert_no_file "app/operations/v1/posts/index_operation.rb"
    assert_no_file "app/operations/v1/posts/create_operation.rb"
    assert_no_file "app/forms/v1/posts/create_form.rb"
  end
end
