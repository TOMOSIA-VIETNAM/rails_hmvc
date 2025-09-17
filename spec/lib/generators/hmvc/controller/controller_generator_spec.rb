# frozen_string_literal: true

# spec/lib/generators/hmvc/controller/controller_generator_spec.rb
require 'spec_helper'
require 'generators/hmvc/controller/controller_generator'

RSpec.describe RailsHmvc::Generators::ControllerGenerator, type: :generator do
  # helper tạo config mẫu mà generator sẽ dùng
  let(:config) do
    {
      'type' => 'web',
      'controllers' => {
        'parent' => 'ApplicationController',
        'actions' => %w[index show new create update destroy edit]
      },
      'operations' => {
        'parent' => 'BaseOperation',
        'steps' => 'step1,step2'
      },
      'forms' => {
        'parent' => 'BaseForm',
        'actions' => %w[index show new create edit update],
        'skip_actions' => ['index']
      }
    }
  end

  # build generator with stubs for load_config_for_type so initialize won't try to load real files
  def build_generator(name: 'admin/users', opts: {})
    # Stub the instance method load_config_for_type before instantiation so initialize uses our config
    allow_any_instance_of(RailsHmvc::Generators::ControllerGenerator)
      .to receive(:load_config_for_type).and_return(config)

    # instantiate generator. Thor/Rails generators accept args, options, destination_root:
    described_class.new([name], opts, destination_root: destination_root)
  end

  let(:destination_root) { Dir.mktmpdir('genspec') }

  after do
    FileUtils.remove_entry(destination_root) if Dir.exist?(destination_root)
  end

  describe 'defaults from config (initialize)' do
    it 'loads config and sets defaults' do
      g = build_generator(name: 'admin/users', opts: {})
      # internal @options should be set from config
      expect(g.send(:controller_path)).to eq('admin/users_controller')
      # default actions array from config
      expect(g.send(:actions)).to include('index', 'show', 'create')
      # parent controller default from config
      expect(g.send(:parent_controller_class)).to eq('ApplicationController')
    end

    it 'overrides config with provided options' do
      g = build_generator(name: 'admin/users', opts: { 'parent' => 'Admin::BaseController', 'actions' => 'index,show' })
      expect(g.send(:parent_controller_class)).to eq('Admin::BaseController')
      expect(g.send(:actions)).to eq(%w[index show])
    end
  end

  describe 'path and class helper methods' do
    let(:g) { build_generator(name: 'admin/users', opts: {}) }

    it 'computes controller_path correctly' do
      expect(g.send(:controller_path)).to eq('admin/users_controller')
    end

    it 'computes resource and controller class names' do
      expect(g.send(:resource_class)).to eq('Admin::Users')
      expect(g.send(:controller_class_name)).to eq('Admin::UsersController')
    end

    it 'operation_class_for returns expected name' do
      expect(g.send(:operation_class_for, 'create')).to eq('Admin::Users::CreateOperation')
    end
  end

  describe 'http method, route and comment helpers' do
    let(:g) { build_generator(name: 'admin/users', opts: {}) }

    it 'maps http methods' do
      expect(g.send(:http_method_for, 'index')).to eq('GET')
      expect(g.send(:http_method_for, 'show')).to eq('GET')
      expect(g.send(:http_method_for, 'create')).to eq('POST')
      expect(g.send(:http_method_for, 'update')).to eq('PUT')
      expect(g.send(:http_method_for, 'destroy')).to eq('DELETE')
      expect(g.send(:http_method_for, 'edit')).to eq('GET')
    end

    it 'builds route path with and without id' do
      expect(g.send(:route_path_for, 'index')).to eq('/admin/users')
      expect(g.send(:route_path_for, 'show')).to eq('/admin/users/:id')
      expect(g.send(:route_path_for, 'edit')).to eq('/admin/users/:id')
      expect(g.send(:route_path_for, 'create')).to eq('/admin/users')
    end

    it 'action_comment_for combines method and path' do
      expect(g.send(:action_comment_for, 'index')).to eq('GET /admin/users')
      expect(g.send(:action_comment_for, 'show')).to eq('GET /admin/users/:id')
      expect(g.send(:action_comment_for, 'create')).to eq('POST /admin/users')
    end
  end

  describe 'actions parsing' do
    it 'parses actions when provided as comma string' do
      g = build_generator(name: 'admin/users', opts: { 'actions' => 'index,show,create' })
      expect(g.send(:actions)).to eq(%w[index show create])
    end

    it 'returns array when config provided array' do
      g = build_generator(name: 'admin/users', opts: {})
      expect(g.send(:actions)).to be_an(Array)
    end
  end

  describe 'render responses (API vs web) - api' do
    it 'render_api_response index returns collection rendering when operations are enabled' do
      g = build_generator(name: 'admin/users', opts: { 'type' => 'api', 'skip_operation' => false })
      # ensure skip_operation? is false
      expect(g.send(:skip_operation?)).to be_falsey
      str = g.send(:render_api_response, 'index')
      expect(str).to include('render_collection(')
      expect(str).to include('pagination_meta([])')
    end

    it 'render_api_response create returns resource with :created' do
      g = build_generator(name: 'admin/users', opts: { 'type' => 'api', 'skip_operation' => false })
      str = g.send(:render_api_response, 'create')
      expect(str).to include('status: :created')
      expect(str).to include('render_resource(')
    end

    it 'render_api_response when skip_operation returns head no_content' do
      g = build_generator(name: 'admin/users', opts: { 'type' => 'api', 'skip_operation' => true })
      expect(g.send(:skip_operation?)).to be_truthy
      expect(g.send(:render_api_response, 'index')).to eq('head :no_content')
    end
  end

  describe 'render responses (web) - behavior with/without operations' do
    it 'render_web_response index renders index' do
      g = build_generator(name: 'admin/users', opts: { 'type' => 'web' })
      expect(g.send(:render_web_response, 'index')).to eq('render :index')
    end

    it 'render_web_response create returns render :new when skip_operation' do
      g = build_generator(name: 'admin/users', opts: { 'type' => 'web', 'skip_operation' => true })
      expect(g.send(:render_web_response, 'create')).to eq('render :new')
    end

    it 'render_web_response create returns conditional redirect string when operations enabled' do
      g = build_generator(name: 'admin/users', opts: { 'type' => 'web', 'skip_operation' => false })
      out = g.send(:render_web_response, 'create')
      expect(out).to include('if operator.success?')
      expect(out).to include('redirect_to')
      expect(out).to include('was successfully created.')
    end

    it 'render_web_response destroy returns head no_content when skip_operation' do
      g = build_generator(name: 'admin/users', opts: { 'type' => 'web', 'skip_operation' => true })
      expect(g.send(:render_web_response, 'destroy')).to eq('head :no_content')
    end

    it 'render_web_response destroy returns conditional redirect when operations enabled' do
      g = build_generator(name: 'admin/users', opts: { 'type' => 'web', 'skip_operation' => false })
      out = g.send(:render_web_response, 'destroy')
      expect(out).to include('if operator.success?')
      expect(out).to include('render :index, alert:')
    end
  end

  describe 'create_controller' do
    it 'invokes template unless skip_controller' do
      g = build_generator(name: 'admin/users', opts: { 'skip_controller' => false })
      # stub template method to capture call
      expect(g).to receive(:template).with('controller.rb', 'app/controllers/admin/users_controller.rb')
      g.create_controller
    end

    it 'skips template when skip_controller is true' do
      g = build_generator(name: 'admin/users', opts: { 'skip_controller' => true })
      expect(g).not_to receive(:template)
      g.create_controller
    end
  end

  describe 'create_operations' do
    it 'invokes rails generator for each action' do
      g = build_generator(name: 'admin/users', opts: { 'actions' => 'index,show,create', 'skip_operation' => false, 'type' => 'web' })
      # stub Rails::Generators.invoke to assert calls
      expect(Rails::Generators).to receive(:invoke).exactly(3).times.with(anything, anything, destination_root: destination_root)
      g.create_operations
    end

    it 'does nothing when skip_operation is true' do
      g = build_generator(name: 'admin/users', opts: { 'actions' => 'index,show', 'skip_operation' => true })
      expect(Rails::Generators).not_to receive(:invoke)
      g.create_operations
    end
  end

  describe 'create_forms' do
    it 'invokes form generator only for configured form actions present in controller actions and not skipped' do
      # config[:forms]['actions'] = %w[index show new create edit update], skip_actions = ['index']
      g = build_generator(name: 'admin/users', opts: { 'actions' => 'index,show,new,create,edit', 'skip_form' => false })
      # Expect invokes for show, new, create, edit but not index (skipped in config)
      expect(Rails::Generators).to receive(:invoke).exactly(4).times.with(anything, anything, destination_root: destination_root)
      g.create_forms
    end

    it 'does nothing when skip_form is true' do
      g = build_generator(name: 'admin/users', opts: { 'actions' => 'show,new', 'skip_form' => true })
      expect(Rails::Generators).not_to receive(:invoke)
      g.create_forms
    end

    it 'does not invoke forms for actions not present in controller actions' do
      g = build_generator(name: 'admin/users', opts: { 'actions' => 'index', 'skip_form' => false })
      # index is in skip_actions in config, so zero invocations
      expect(Rails::Generators).not_to receive(:invoke)
      g.create_forms
    end
  end
end
