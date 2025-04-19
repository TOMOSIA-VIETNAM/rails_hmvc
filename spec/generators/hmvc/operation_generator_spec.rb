require 'spec_helper'
require 'generators/hmvc/operation/operation_generator'

RSpec.describe RailsHmvc::Generators::OperationGenerator, type: :generator do
  destination File.expand_path('../../../tmp', __FILE__)

  before do
    prepare_destination
    FileUtils.mkdir_p("#{destination_root}/config")
    File.write("#{destination_root}/config/rails_hmvc.yml", config_content)
  end

  describe 'generator runs with resource' do
    before { run_generator ['posts/process_payment', '--steps=validate,process,notify'] }

    it 'creates operation file in resource namespace' do
      expect(file('app/operations/v1/posts/process_payment_operation.rb')).to exist
    end

    it 'includes correct class definition' do
      expect(file('app/operations/v1/posts/process_payment_operation.rb'))
        .to contain('module V1::Posts')
        .and contain('class ProcessPaymentOperation < ApplicationOperation')
    end

    it 'includes specified steps' do
      operation_file = file('app/operations/v1/posts/process_payment_operation.rb')
      expect(operation_file).to contain('step_validate')
      expect(operation_file).to contain('step_process')
      expect(operation_file).to contain('step_notify')
    end
  end

  describe 'generator runs without resource' do
    before { run_generator ['process_data', '--steps=fetch,transform,load'] }

    it 'creates operation file in version namespace' do
      expect(file('app/operations/v1/process_data_operation.rb')).to exist
    end

    it 'includes correct class definition' do
      expect(file('app/operations/v1/process_data_operation.rb'))
        .to contain('module V1')
        .and contain('class ProcessDataOperation < ApplicationOperation')
    end

    it 'includes specified steps' do
      operation_file = file('app/operations/v1/process_data_operation.rb')
      expect(operation_file).to contain('step_fetch')
      expect(operation_file).to contain('step_transform')
      expect(operation_file).to contain('step_load')
    end
  end

  describe 'generator runs with custom parent' do
    before { run_generator ['custom/operation', '--parent=CustomOperation'] }

    it 'uses custom parent class' do
      expect(file('app/operations/v1/custom/operation_operation.rb'))
        .to contain('class OperationOperation < CustomOperation')
    end
  end

  describe 'generator runs with default step' do
    before { run_generator ['simple_operation'] }

    it 'includes default process step' do
      expect(file('app/operations/v1/simple_operation_operation.rb'))
        .to contain('step_process')
    end
  end

  private

  def config_content
    <<-YAML
default: &default
  type: api
  parent_operation: ApplicationOperation

development:
  <<: *default
    YAML
  end
end
