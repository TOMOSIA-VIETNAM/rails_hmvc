# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/errors/api_error'

RSpec.describe Errors::APIError do
  describe '#initialize' do
    context 'when initialized with default parameters' do
      let(:error) { described_class.new }

      it 'sets default values' do
        expect(error.status).to eq(500)
        expect(error.code).to eq('api_error')
        expect(error.message).to eq('Errors::APIError')
        expect(error.detail).to be_nil
      end
    end

    context 'when initialized with only message' do
      let(:error) { described_class.new('Something went wrong') }

      it 'uses custom message with default status and code' do
        expect(error.message).to eq('Something went wrong')
        expect(error.status).to eq(500)
        expect(error.code).to eq('api_error')
        expect(error.detail).to be_nil
      end
    end

    context 'when initialized with all custom parameters' do
      let(:error) do
        described_class.new(
          'Custom message', 
          status: 400, 
          code: 'custom_error', 
          detail: 'Error details'
        )
      end

      it 'sets all custom values correctly' do
        expect(error.status).to eq(400)
        expect(error.code).to eq('custom_error')
        expect(error.message).to eq('Custom message')
        expect(error.detail).to eq('Error details')
      end
    end

    context 'when initialized with partial parameters' do
      let(:error) { described_class.new('Partial error', status: 422) }

      it 'uses custom values and defaults for others' do
        expect(error.message).to eq('Partial error')
        expect(error.status).to eq(422)
        expect(error.code).to eq('api_error')  # default
        expect(error.detail).to be_nil
      end
    end

    context 'with edge cases' do
      it 'handles nil message correctly' do
        error = described_class.new(nil)
        expect(error.message).to eq('Errors::APIError')
      end

      it 'handles empty string message' do
        error = described_class.new('')
        expect(error.message).to eq('')
      end

      it 'handles nil detail' do
        error = described_class.new('Test', detail: nil)
        expect(error.detail).to be_nil
      end
    end
  end

  describe '#to_hash' do
    context 'with default parameters' do
      let(:error) { described_class.new }

      it 'returns hash with correct structure' do
        hash = error.to_hash
        expect(hash).to eq({
          status: 500,
          code: 'api_error',
          message: 'Errors::APIError',
          detail: nil
        }.compact)
      end

      it 'excludes nil values when using compact' do
        hash = error.to_hash
        expect(hash).not_to have_key(:detail)
      end
    end

    context 'with all parameters set' do
      let(:error) do
        described_class.new(
          'API failed', 
          status: 503, 
          code: 'service_unavailable', 
          detail: 'Database connection failed'
        )
      end

      it 'includes all values in hash' do
        hash = error.to_hash
        expect(hash).to eq({
          status: 503,
          code: 'service_unavailable',
          message: 'API failed',
          detail: 'Database connection failed'
        })
      end
    end
  end

  describe 'inheritance and behavior' do
    it 'inherits from BaseError' do
      expect(described_class.superclass).to eq(Errors::BaseError)
    end

    it 'is a StandardError' do
      error = described_class.new('Test error')
      expect(error).to be_a(StandardError)
    end

    it 'can be raised and rescued' do
      expect { raise described_class, 'Test error' }.to raise_error(described_class, 'Test error')
    end

    it 'can be rescued as StandardError' do
      expect { raise described_class, 'Test error' }.to raise_error(StandardError)
    end
  end

  describe 'attribute readers' do
    let(:error) do
      described_class.new(
        'Test', 
        status: 404, 
        code: 'not_found', 
        detail: 'Resource missing'
      )
    end

    it 'provides read access to status' do
      expect(error.status).to eq(404)
    end

    it 'provides read access to code' do
      expect(error.code).to eq('not_found')
    end

    it 'provides read access to detail' do
      expect(error.detail).to eq('Resource missing')
    end

    it 'provides read access to message via StandardError' do
      expect(error.message).to eq('Test')
    end
  end
end
