# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsHmvc do
  it 'has a version number' do
    expect(RailsHmvc::VERSION).not_to be_nil
  end

  describe 'Error class' do
    it 'is defined' do
      expect(defined?(RailsHmvc::Error)).to eq('constant')
    end

    it 'inherits from StandardError' do
      expect(RailsHmvc::Error.superclass).to eq(StandardError)
    end
  end

  describe 'Dependencies' do
    it 'requires core dependencies' do
      expect(defined?(Rails)).to eq('constant')
      expect(defined?(ActiveModel)).to eq('constant')
      expect(defined?(ActiveModelSerializers)).to eq('constant')
    end
  end

  describe 'RuboCop integration' do
    context 'when RuboCop is available' do
      before do
        # Simulate RuboCop being available
        stub_const('RuboCop', Class.new) unless defined?(RuboCop)
      end

      it 'loads RuboCop extension' do
        # Re-require to trigger RuboCop integration
        load 'rails_hmvc.rb'
        expect($LOADED_FEATURES).to include(match('rubocop-rails-hmvc'))
      end
    end
  end
end
