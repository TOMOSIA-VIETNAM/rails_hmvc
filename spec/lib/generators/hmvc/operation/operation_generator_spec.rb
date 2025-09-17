# frozen_string_literal: true

require 'spec_helper'
require 'rails/generators'
require 'rails/generators/actions'
require 'rails/generators/base'
require 'rails/generators/generated_attribute'
require 'generators/hmvc/generator_helpers'
require 'generators/hmvc/operation/operation_generator'

RSpec.describe RailsHmvc::Generators::OperationGenerator, type: :generator do
  let(:generator) { described_class.new([name], options, {}) }
  let(:name) { 'user' }
  let(:options) { {} }

  before do
    allow_any_instance_of(described_class).to receive(:load_config_for_type).and_return(
      'type' => 'api',
      'operations' => {
        'parent' => 'BaseOperation',
        'steps'  => 'validate,save'
      }
    )
  end

  describe '#actions' do
    it 'returns [] when nil' do
      options[:actions] = nil
      expect(generator.send(:actions)).to eq([])
    end

    it 'splits string into array' do
      options[:actions] = 'index,create'
      expect(generator.send(:actions)).to eq(%w[index create])
    end

    it 'keeps array as is' do
      options[:actions] = %w[show edit]
      expect(generator.send(:actions)).to eq(%w[show edit])
    end
  end

  describe '#steps and #step_methods' do
    context 'when no steps provided' do
      before do
        allow_any_instance_of(described_class).to receive(:load_config_for_type).and_return(
          'type' => 'api',
          'operations' => {
            'parent' => 'BaseOperation'
          }
        )
      end

      it 'returns [] when nil' do
        generator = described_class.new([name], {}, {})
        expect(generator.send(:steps)).to eq([])
      end
    end

    context 'when steps provided as string' do
      before do
        allow_any_instance_of(described_class).to receive(:load_config_for_type).and_return(
          'type' => 'api',
          'operations' => {
            'parent' => 'BaseOperation',
            'steps'  => 'validate,save'
          }
        )
      end

      it 'splits string steps' do
        generator = described_class.new([name], {}, {})
        expect(generator.send(:steps)).to eq(%w[validate save])
      end

      it 'normalizes step methods' do
        generator = described_class.new([name], {}, {})
        expect(generator.send(:step_methods)).to eq([:step_validate, :step_save])
      end
    end
  end

  describe '#operation_class_name and #operation_path' do
    context 'without current_action' do
      it 'uses file_name' do
        expect(generator.send(:operation_class_name)).to eq('User')
        expect(generator.send(:operation_path)).to eq('user_operation')
      end
    end

    context 'with current_action' do
      before { generator.instance_variable_set(:@current_action, 'index') }

      it 'camelizes action' do
        expect(generator.send(:operation_class_name)).to eq('Index')
        expect(generator.send(:operation_path)).to eq('users/index_operation')
      end
    end
  end

  describe '#create_operations' do
    it 'calls create_single_operation when no actions' do
      expect(generator).to receive(:create_single_operation)
      generator.create_operations
    end

    it 'calls create_operation_for when actions exist' do
      options[:actions] = 'index,create'
      expect(generator).to receive(:create_operation_for).with('index')
      expect(generator).to receive(:create_operation_for).with('create')
      generator.create_operations
    end
  end
end
