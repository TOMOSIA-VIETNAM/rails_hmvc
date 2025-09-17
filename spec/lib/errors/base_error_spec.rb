# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/errors/base_error'

RSpec.describe Errors::BaseError do
  describe '#initialize' do
    context 'when initialized with no parameters' do
      let(:error) { described_class.new }

      it 'sets all attributes to nil' do
        expect(error.status).to be_nil
        expect(error.code).to be_nil
        expect(error.detail).to be_nil
        expect(error.message).to eq('Errors::BaseError')
      end
    end

    context 'when initialized with message only' do
      let(:error) { described_class.new('Something went wrong') }

      it 'sets message and leaves other attributes nil' do
        expect(error.message).to eq('Something went wrong')
        expect(error.status).to be_nil
        expect(error.code).to be_nil
        expect(error.detail).to be_nil
      end
    end

    context 'when initialized with message and keyword arguments' do
      let(:error) do
        described_class.new(
          'Custom error message',
          status: 422,
          code: 'validation_error',
          detail: "Field 'email' is invalid"
        )
      end

      it 'sets all attributes correctly' do
        expect(error.message).to eq('Custom error message')
        expect(error.status).to eq(422)
        expect(error.code).to eq('validation_error')
        expect(error.detail).to eq("Field 'email' is invalid")
      end
    end

    context 'when initialized with partial keyword arguments' do
      let(:error) { described_class.new('Partial error', status: 500, code: 'server_error') }

      it 'sets provided attributes and leaves others nil' do
        expect(error.message).to eq('Partial error')
        expect(error.status).to eq(500)
        expect(error.code).to eq('server_error')
        expect(error.detail).to be_nil
      end
    end

    context 'with edge cases' do
      it 'handles nil message' do
        error = described_class.new(nil, status: 400)
        expect(error.message).to eq('Errors::BaseError')
        expect(error.status).to eq(400)
      end

      it 'handles empty string message' do
        error = described_class.new('', code: 'empty_error')
        expect(error.message).to eq('')
        expect(error.code).to eq('empty_error')
      end

      it 'handles zero status code' do
        error = described_class.new('Zero status', status: 0)
        expect(error.status).to eq(0)
      end

      it 'handles negative status code' do
        error = described_class.new('Negative status', status: -1)
        expect(error.status).to eq(-1)
      end

      it 'handles empty string for code and detail' do
        error = described_class.new('Test', code: '', detail: '')
        expect(error.code).to eq('')
        expect(error.detail).to eq('')
      end
    end
  end

  describe '#to_hash' do
    context 'when all attributes are nil' do
      let(:error) { described_class.new }

      it 'returns hash with only message (compact removes nils)' do
        hash = error.to_hash
        expect(hash).to eq({ message: 'Errors::BaseError' })
      end

      it 'excludes nil values due to compact' do
        hash = error.to_hash
        expect(hash).not_to have_key(:status)
        expect(hash).not_to have_key(:code)
        expect(hash).not_to have_key(:detail)
      end
    end

    context 'when some attributes are set' do
      let(:error) { described_class.new('Partial error', status: 404, code: 'not_found') }

      it 'includes only non-nil values' do
        hash = error.to_hash
        expect(hash).to eq({
          status: 404,
          code: 'not_found',
          message: 'Partial error'
        })
      end

      it 'excludes nil detail' do
        hash = error.to_hash
        expect(hash).not_to have_key(:detail)
      end
    end

    context 'when all attributes are set' do
      let(:error) do
        described_class.new(
          'Complete error',
          status: 500,
          code: 'internal_error',
          detail: 'Database connection failed'
        )
      end

      it 'includes all attributes' do
        hash = error.to_hash
        expect(hash).to eq({
          status: 500,
          code: 'internal_error',
          message: 'Complete error',
          detail: 'Database connection failed'
        })
      end

      it 'maintains correct key order' do
        hash = error.to_hash
        expect(hash.keys).to eq([:status, :code, :message, :detail])
      end
    end

    context 'with edge case values' do
      it 'includes zero status' do
        error = described_class.new('Zero', status: 0)
        hash = error.to_hash
        expect(hash[:status]).to eq(0)
      end

      it 'includes empty strings' do
        error = described_class.new('', code: '', detail: '')
        hash = error.to_hash
        expect(hash).to eq({
          code: '',
          message: '',
          detail: ''
        })
      end

      it 'includes false values' do
        error = described_class.new('Test', status: false)
        hash = error.to_hash
        expect(hash[:status]).to eq(false)
      end
    end
  end

  describe 'inheritance and behavior' do
    it 'inherits from StandardError' do
      expect(described_class.superclass).to eq(StandardError)
    end

    it 'can be raised and caught' do
      expect {
        raise described_class.new('Test error')
      }.to raise_error(described_class, 'Test error')
    end

    it 'can be caught as StandardError' do
      expect {
        raise described_class.new('Test error')
      }.to raise_error(StandardError)
    end

    it 'preserves error message in backtrace' do
      begin
        raise described_class.new('Detailed error message')
      rescue => e
        expect(e.message).to eq('Detailed error message')
      end
    end
  end

  describe 'attribute readers' do
    let(:error) do
      described_class.new(
        'Test message',
        status: 422,
        code: 'validation_failed',
        detail: 'Email format is invalid'
      )
    end

    it 'provides read access to status' do
      expect(error.status).to eq(422)
    end

    it 'provides read access to code' do
      expect(error.code).to eq('validation_failed')
    end

    it 'provides read access to detail' do
      expect(error.detail).to eq('Email format is invalid')
    end

    it 'provides read access to message via StandardError' do
      expect(error.message).to eq('Test message')
    end

    context 'when attributes are nil' do
      let(:error) { described_class.new('Only message') }

      it 'returns nil for unset attributes' do
        expect(error.status).to be_nil
        expect(error.code).to be_nil
        expect(error.detail).to be_nil
      end
    end
  end

  describe 'immutability of attributes' do
    let(:error) { described_class.new('Test', status: 500, code: 'error', detail: 'details') }

    it 'does not provide writers for status' do
      expect(error).not_to respond_to(:status=)
    end

    it 'does not provide writers for code' do
      expect(error).not_to respond_to(:code=)
    end

    it 'does not provide writers for detail' do
      expect(error).not_to respond_to(:detail=)
    end
  end

  describe 'error serialization' do
    context 'for logging and debugging' do
      let(:error) do
        described_class.new(
          'Service unavailable',
          status: 503,
          code: 'service_error',
          detail: 'External API timeout'
        )
      end

      it 'can be converted to JSON via to_hash' do
        hash = error.to_hash
        json_string = hash.to_json
        
        expect(json_string).to be_a(String)
        parsed = JSON.parse(json_string)
        expect(parsed['message']).to eq('Service unavailable')
        expect(parsed['status']).to eq(503)
      end

      it 'supports inspect for debugging' do
        inspect_output = error.inspect
        expect(inspect_output).to include('BaseError')
        expect(inspect_output).to include('Service unavailable')
      end
    end
  end

  describe 'class methods and constants' do
    it 'has the correct class name' do
      expect(described_class.name).to eq('Errors::BaseError')
    end

    it 'is defined in the Errors module' do
      expect(described_class.name).to start_with('Errors::')
    end
  end

  describe 'integration scenarios' do
    context 'when used as base class for inheritance' do
      let(:child_class) do
        Class.new(described_class) do
          def initialize(message = nil, status: 400, code: 'child_error', detail: nil)
            super(message, status: status, code: code, detail: detail)
          end
        end
      end

      it 'allows child classes to override defaults' do
        error = child_class.new('Child error')
        expect(error.status).to eq(400)
        expect(error.code).to eq('child_error')
        expect(error.message).to eq('Child error')
      end

      it 'child class inherits to_hash method' do
        error = child_class.new('Child', detail: 'Child detail')
        hash = error.to_hash
        
        expect(hash[:status]).to eq(400)
        expect(hash[:code]).to eq('child_error')
        expect(hash[:detail]).to eq('Child detail')
      end
    end
  end
end
