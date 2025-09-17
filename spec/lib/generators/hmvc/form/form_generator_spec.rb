# frozen_string_literal: true

require 'spec_helper'
require 'generators/hmvc/form/form_generator'

RSpec.describe RailsHmvc::Generators::FormGenerator, type: :generator do
  let(:config) do
    {
      'type' => 'web',
      'forms' => {
        'parent' => 'BaseForm'
      }
    }
  end

  let(:destination_root) { Dir.mktmpdir('formgenspec') }

  after do
    FileUtils.remove_entry(destination_root) if Dir.exist?(destination_root)
  end

  def build_generator(name: 'user', opts: {})
    allow_any_instance_of(described_class)
      .to receive(:load_config_for_type).and_return(config)

    described_class.new([name], opts, destination_root: destination_root)
  end

  describe 'initialize and defaults' do
    it 'sets defaults from config' do
      g = build_generator(name: 'user')
      expect(g.send(:parent_form_class)).to eq('BaseForm')
    end

    it 'uses provided options over config' do
      g = build_generator(name: 'user', opts: { 'parent' => 'CustomForm' })
      expect(g.send(:parent_form_class)).to eq('CustomForm')
    end
  end

  describe '#actions' do
    it 'returns [] when no actions' do
      g = build_generator
      expect(g.send(:actions)).to eq([])
    end

    it 'parses string into array' do
      g = build_generator(opts: { 'actions' => 'create,update' })
      expect(g.send(:actions)).to eq(%w[create update])
    end

    it 'returns array when array provided' do
      g = build_generator(opts: { 'actions' => %w[create destroy] })
      expect(g.send(:actions)).to eq(%w[create destroy])
    end
  end

  describe '#parse_attributes' do
    it 'returns default name:string when nil' do
      g = build_generator(opts: { 'attributes' => nil })
      attrs = g.send(:parse_attributes, nil)
      expect(attrs).to eq([{ prop: :name, type: 'string' }])
    end

    it 'parses comma separated name:type' do
      g = build_generator(opts: { 'attributes' => 'email:string,age:integer' })
      attrs = g.send(:parse_attributes, 'email:string,age:integer')
      expect(attrs).to eq([{ prop: 'email', type: 'string' }, { prop: 'age', type: 'integer' }])
    end
  end

  describe '#attribute_definitions' do
    it 'renders attributes with types' do
      g = build_generator(opts: { 'attributes' => 'email:string,age:integer' })
      defs = g.send(:attribute_definitions)
      expect(defs).to include('attribute :email, :string')
      expect(defs).to include('attribute :age, :integer')
    end

    it 'renders attributes without type' do
      g = build_generator
      defs = g.send(:attribute_definitions)
      expect(defs).to include('attribute :name, :string')
    end
  end

  describe 'form path and class name' do
    it 'computes form_path without action' do
      g = build_generator(name: 'user')
      expect(g.send(:form_path)).to eq('user_form')
      expect(g.send(:form_class_name)).to eq('User')
    end

    it 'computes form_path and form_class_name with action' do
      g = build_generator(name: 'user', opts: { 'actions' => 'create' })
      g.instance_variable_set(:@current_action, 'create')
      expect(g.send(:form_path)).to eq('users/create_form')
      expect(g.send(:form_class_name)).to eq('Create')
    end
  end

  describe '#create_forms' do
    it 'calls create_single_form when no actions' do
      g = build_generator(name: 'user')
      expect(g).to receive(:create_single_form)
      g.create_forms
    end

    it 'calls create_form_for for each action when actions present' do
      g = build_generator(name: 'user', opts: { 'actions' => 'create,update' })
      expect(g).to receive(:create_form_for).with('create')
      expect(g).to receive(:create_form_for).with('update')
      g.create_forms
    end
  end
end
