require 'spec_helper'
require 'generators/hmvc/init/init_generator'

RSpec.describe RailsHmvc::Generators::InitGenerator, type: :generator do
  destination File.expand_path('../../../tmp', __FILE__)

  before do
    prepare_destination
    FileUtils.mkdir_p("#{destination_root}/config")
    File.write("#{destination_root}/config/application.rb", application_rb_content)
  end

  describe 'generator runs' do
    before { run_generator }

    it 'creates HMVC directories' do
      %w[
        app/controllers
        app/operations
        app/forms
        app/serializers
        app/models
        lib/errors
      ].each do |dir|
        expect(file(dir)).to exist
      end
    end

    it 'creates configuration file' do
      expect(file('config/rails_hmvc.yml')).to exist
      expect(file('config/rails_hmvc.yml')).to contain('type: api')
    end

    it 'creates base error class' do
      expect(file('lib/errors/application_error.rb')).to exist
      expect(file('lib/errors/application_error.rb')).to contain('class ApplicationError < StandardError')
    end

    it 'creates base controllers' do
      expect(file('app/controllers/main_controller.rb')).to exist
      expect(file('app/controllers/api_controller.rb')).to exist
    end

    it 'modifies application.rb' do
      expect(file('config/application.rb')).to contain('config.before_configuration')
      expect(file('config/application.rb')).to contain('config.autoload_paths')
    end

    it 'adds routes' do
      expect(file('config/routes.rb')).to contain("scope module: :v1, path: 'v1'")
    end
  end

  private

  def application_rb_content
    <<-RUBY
require_relative "boot"
require "rails"
module #{app_name}
  class Application < Rails::Application
  end
end
    RUBY
  end

  def app_name
    'TestApp'
  end
end
