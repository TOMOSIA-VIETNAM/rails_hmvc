require 'spec_helper'
require 'generators/hmvc/resources/resources_generator'

RSpec.describe RailsHmvc::Generators::ResourcesGenerator, type: :generator do
  destination File.expand_path('../../../tmp', __FILE__)

  before do
    prepare_destination
    FileUtils.mkdir_p("#{destination_root}/config")
    File.write("#{destination_root}/config/routes.rb", routes_content)
    File.write("#{destination_root}/config/rails_hmvc.yml", config_content)
  end

  describe 'generator runs' do
    before { run_generator ['post'] }

    it 'creates controller file' do
      expect(file('app/controllers/v1/posts_controller.rb')).to exist
      expect(file('app/controllers/v1/posts_controller.rb')).to contain('class PostsController < V1Controller')
    end

    it 'creates operation files' do
      %w[index show create update destroy].each do |action|
        expect(file("app/operations/v1/posts/#{action}_operation.rb")).to exist
        expect(file("app/operations/v1/posts/#{action}_operation.rb")).to contain("class #{action.camelize}Operation < ApplicationOperation")
      end
    end

    it 'creates form files' do
      %w[create update].each do |action|
        expect(file("app/forms/v1/posts/#{action}_form.rb")).to exist
        expect(file("app/forms/v1/posts/#{action}_form.rb")).to contain("class #{action.camelize}Form < ApplicationForm")
      end
    end

    it 'creates serializer file' do
      expect(file('app/serializers/v1/post_serializer.rb')).to exist
      expect(file('app/serializers/v1/post_serializer.rb')).to contain('class PostSerializer < ApplicationSerializer')
    end

    it 'adds routes' do
      expect(file('config/routes.rb')).to contain('resources :posts')
    end
  end

  private

  def routes_content
    <<-RUBY
Rails.application.routes.draw do
  scope module: :v1, path: 'v1' do
  end
end
    RUBY
  end

  def config_content
    <<-YAML
default: &default
  type: api
  parent_controller: ApplicationController
  parent_operation: ApplicationOperation
  parent_form: ApplicationForm
  parent_serializer: ApplicationSerializer

development:
  <<: *default
    YAML
  end
end
