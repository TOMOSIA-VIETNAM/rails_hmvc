# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'generators/hmvc/generator_helpers'

RSpec.describe RailsHmvc::Generators::GeneratorHelpers do
  let(:dummy_class) do
    Class.new do
      include RailsHmvc::Generators::GeneratorHelpers
      attr_accessor :destination_root, :class_path, :human_name
    end
  end

  let(:instance) { dummy_class.new }

  describe '#load_config' do
    let(:config_file) { File.join(tmpdir, 'config', 'rails_hmvc.yml') }
    let(:tmpdir) { Dir.mktmpdir }

    before do
      instance.destination_root = tmpdir
      FileUtils.mkdir_p(File.dirname(config_file))
    end

    context 'when file does not exist' do
      it 'returns empty hash' do
        expect(instance.load_config).to eq({})
      end
    end

    context 'when file exists with valid YAML' do
      before do
        File.write(config_file, { 'type' => 'web', 'forms' => { 'parent' => 'BaseForm' } }.to_yaml)
      end

      it 'returns parsed config' do
        config = instance.load_config
        expect(config['type']).to eq('web')
        expect(config['forms']['parent']).to eq('BaseForm')
      end
    end

    context 'when file exists but invalid YAML' do
      before do
        File.write(config_file, 'foo: bar: :baz') # invalid yaml
      end

      it 'returns empty hash' do
        expect(instance.load_config).to eq({})
      end
    end
  end

  describe '#load_config_for_type' do
    before do
      allow(instance).to receive(:load_config).and_return({
        'type' => 'web',
        'common' => 'shared',
        'web' => { 'foo' => 'bar' },
        'api' => { 'foo' => 'baz' }
      })
    end

    it 'merges base config with web config by default' do
      config = instance.load_config_for_type
      expect(config).to include('foo' => 'bar', 'common' => 'shared', 'type' => 'web')
    end

    it 'merges base config with api config when type = api' do
      config = instance.load_config_for_type('api')
      expect(config).to include('foo' => 'baz', 'common' => 'shared')
    end

    it 'returns base config only if type not found' do
      config = instance.load_config_for_type('unknown')
      expect(config).to include('common' => 'shared', 'type' => 'web')
      expect(config).not_to include('foo')
    end
  end

  describe '#namespace_path' do
    it 'joins class_path with /' do
      instance.class_path = %w[admin users]
      expect(instance.namespace_path).to eq('admin/users')
    end

    it 'returns empty string when no class_path' do
      instance.class_path = []
      expect(instance.namespace_path).to eq('')
    end
  end

  describe '#namespace_name' do
    it 'camelizes and joins with ::' do
      instance.class_path = %w[admin users]
      expect(instance.namespace_name).to eq('Admin::Users')
    end

    it 'returns empty string when no class_path' do
      instance.class_path = []
      expect(instance.namespace_name).to eq('')
    end
  end

  describe '#singular_human_name' do
    it 'returns singularized version of human_name' do
      instance.human_name = 'Users'
      expect(instance.singular_human_name).to eq('User')
    end
  end
end
