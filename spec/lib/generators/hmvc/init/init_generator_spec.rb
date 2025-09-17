# frozen_string_literal: true

require 'spec_helper'
require 'rails/generators'
require 'rails/generators/base'
require 'generators/hmvc/init/init_generator'

RSpec.describe RailsHmvc::Generators::InitGenerator, type: :generator do
  let(:generator) { described_class.new([], {}, destination_root: Dir.mktmpdir) }

  describe '#create_hmvc_directories' do
    it 'calls empty_directory for each expected directory' do
      dirs = %w[
        app/controllers
        app/operations
        app/forms
        app/serializers
        app/models
        lib/errors
        app/controllers/concerns
        config/initializers
      ]

      dirs.each do |dir|
        expect(generator).to receive(:empty_directory).with(dir)
      end

      generator.create_hmvc_directories
    end
  end

  describe '#create_configuration_file' do
    it 'invokes template with correct source and destination' do
      expect(generator).to receive(:template)
        .with('config/rails_hmvc.yml.tt', 'config/rails_hmvc.yml')

      generator.create_configuration_file
    end
  end

  describe '#create_base_error_class' do
    it 'invokes template for application_error and resource_error' do
      expect(generator).to receive(:template)
        .with('errors/application_error.rb.tt', 'lib/errors/application_error.rb')
      expect(generator).to receive(:template)
        .with('errors/resource_error.rb.tt', 'lib/errors/resource_error.rb')

      generator.create_base_error_class
    end
  end

  describe '#create_base_classes' do
    it 'invokes template for controllers, forms and operations' do
      expect(generator).to receive(:template)
        .with('controllers/main_controller.rb.tt', 'app/controllers/main_controller.rb')
      expect(generator).to receive(:template)
        .with('controllers/api_controller.rb.tt', 'app/controllers/api_controller.rb')
      expect(generator).to receive(:template)
        .with('forms/main_form.rb.tt', 'app/forms/main_form.rb')
      expect(generator).to receive(:template)
        .with('operations/main_operation.rb.tt', 'app/operations/main_operation.rb')

      generator.create_base_classes
    end
  end

  describe '#create_concerns' do
    it 'invokes template for renderable and errorable concerns' do
      expect(generator).to receive(:template)
        .with('concerns/renderable.rb.tt', 'app/controllers/concerns/renderable.rb')
      expect(generator).to receive(:template)
        .with('concerns/errorable.rb.tt', 'app/controllers/concerns/errorable.rb')

      generator.create_concerns
    end
  end

  describe '#create_serializers' do
    it 'invokes template for main_serializer and error_serializer' do
      expect(generator).to receive(:template)
        .with('serializers/main_serializer.rb.tt', 'app/serializers/main_serializer.rb')
      expect(generator).to receive(:template)
        .with('errors/error_serializer.rb.tt', 'app/serializers/error_serializer.rb')

      generator.create_serializers
    end
  end

  describe '#app_name' do
    it 'returns the application module name' do
      stub_const('DummyApp::Application', Class.new)
      allow(Rails).to receive(:application).and_return(DummyApp::Application.new)

      expect(generator.send(:app_name)).to eq('DummyApp')
    end
  end
end
