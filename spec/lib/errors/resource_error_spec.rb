# frozen_string_literal: true

require 'spec_helper'
require 'json'
require_relative '../../../lib/errors/resource_error'

RSpec.describe Errors::ResourceError do
  describe '#initialize' do
    context 'when initialized with required resource parameter only' do
      let(:error) { described_class.new(resource: 'User') }

      it 'sets resource and generates default message' do
        expect(error.resource).to eq('User')
        expect(error.message).to eq('Error with resource User')
        expect(error.errors).to eq([nil])
      end

      it 'uses default status, code, and nil detail' do
        expect(error.status).to eq(422)
        expect(error.code).to eq('resource_error')
        expect(error.detail).to be_nil
      end
    end

    context 'when initialized with custom message as string' do
      let(:error) { described_class.new(resource: 'Post', message: 'Post validation failed') }

      it 'uses custom message' do
        expect(error.resource).to eq('Post')
        expect(error.message).to eq('Post validation failed')
        expect(error.errors).to eq(['Post validation failed'])
      end
    end

    context 'when initialized with custom message as array' do
      let(:error) do
        described_class.new(
          resource: 'Comment',
          message: ['Title is required', 'Body is too short', 'Author is invalid']
        )
      end

      it 'stores message array in errors and converts array to string for message' do
        expect(error.resource).to eq('Comment')
        expect(error.errors).to eq(['Title is required', 'Body is too short', 'Author is invalid'])
        expect(error.message).to eq('["Title is required", "Body is too short", "Author is invalid"]')
      end
    end

    context 'when initialized with all custom parameters' do
      let(:error) do
        described_class.new(
          resource: 'Product',
          message: 'Invalid product data',
          status: 400,
          code: 'product_validation_error',
          detail: 'Product price must be positive'
        )
      end

      it 'sets all custom values correctly' do
        expect(error.resource).to eq('Product')
        expect(error.message).to eq('Invalid product data')
        expect(error.errors).to eq(['Invalid product data'])
        expect(error.status).to eq(400)
        expect(error.code).to eq('product_validation_error')
        expect(error.detail).to eq('Product price must be positive')
      end
    end

    context 'with edge cases' do
      it 'handles nil message correctly' do
        error = described_class.new(resource: 'Order', message: nil)
        expect(error.resource).to eq('Order')
        expect(error.message).to eq('Error with resource Order')
        expect(error.errors).to eq([nil])
      end

      it 'handles empty string message' do
        error = described_class.new(resource: 'Invoice', message: '')
        expect(error.resource).to eq('Invoice')
        expect(error.message).to eq('')
        expect(error.errors).to eq([''])
      end

      it 'handles empty array message' do
        error = described_class.new(resource: 'Category', message: [])
        expect(error.resource).to eq('Category')
        expect(error.message).to eq('[]')
        expect(error.errors).to eq([])
      end

      it 'handles array with nil elements' do
        error = described_class.new(resource: 'Tag', message: [nil, 'Valid error', nil])
        expect(error.resource).to eq('Tag')
        expect(error.errors).to eq([nil, 'Valid error', nil])
      end

      it 'handles non-string resource' do
        error = described_class.new(resource: 123)
        expect(error.resource).to eq(123)
        expect(error.message).to eq('Error with resource 123')
      end

      it 'handles symbol resource' do
        error = described_class.new(resource: :user)
        expect(error.resource).to eq(:user)
        expect(error.message).to eq('Error with resource user')
      end
    end
  end

  describe '#to_hash' do
    context 'with default parameters' do
      let(:error) { described_class.new(resource: 'User') }

      it 'includes resource in hash and inherits parent attributes' do
        hash = error.to_hash
        expect(hash).to include(
          resource: 'User',
          status: 422,
          code: 'resource_error',
          message: 'Error with resource User'
        )
      end

      it 'excludes nil detail due to compact in parent class' do
        hash = error.to_hash
        expect(hash).not_to have_key(:detail)
      end
    end

    context 'with all parameters set' do
      let(:error) do
        described_class.new(
          resource: 'Article',
          message: 'Article validation failed',
          status: 400,
          code: 'article_error',
          detail: 'Title and content are required'
        )
      end

      it 'includes all attributes including resource' do
        hash = error.to_hash
        expect(hash).to eq({
                             status: 400,
                             code: 'article_error',
                             message: 'Article validation failed',
                             detail: 'Title and content are required',
                             resource: 'Article'
                           })
      end
    end

    context 'with array message' do
      let(:error) do
        described_class.new(
          resource: 'Form',
          message: ['Name is required', 'Email is invalid']
        )
      end

      it 'includes array message as string in hash' do
        hash = error.to_hash
        expect(hash[:message]).to eq('["Name is required", "Email is invalid"]')
        expect(hash[:resource]).to eq('Form')
      end
    end

    context 'when resource is not a string' do
      let(:error) { described_class.new(resource: { model: 'User', id: 123 }) }

      it 'includes complex resource object' do
        hash = error.to_hash
        expect(hash[:resource]).to eq({ model: 'User', id: 123 })
      end
    end
  end

  describe 'attribute readers' do
    let(:error) do
      described_class.new(
        resource: 'Customer',
        message: ['Email is taken', 'Phone is invalid'],
        status: 409,
        code: 'customer_conflict'
      )
    end

    it 'provides read access to resource' do
      expect(error.resource).to eq('Customer')
    end

    it 'provides read access to errors array' do
      expect(error.errors).to eq(['Email is taken', 'Phone is invalid'])
    end

    it 'inherits access to parent attributes' do
      expect(error.status).to eq(409)
      expect(error.code).to eq('customer_conflict')
      expect(error.detail).to be_nil
    end

    context 'immutability' do
      it 'does not provide writers for resource' do
        expect(error).not_to respond_to(:resource=)
      end

      it 'does not provide writers for errors' do
        expect(error).not_to respond_to(:errors=)
      end

      it 'allows modification of errors array' do
        expect { error.errors << 'new error' }.to change { error.errors.length }.by(1)
      end
    end
  end

  describe 'inheritance and behavior' do
    it 'inherits from APIError' do
      expect(described_class.superclass).to eq(Errors::APIError)
    end

    it 'is also a BaseError and StandardError' do
      error = described_class.new(resource: 'Test')
      expect(error).to be_a(Errors::BaseError)
      expect(error).to be_a(StandardError)
    end

    it 'can be raised and rescued as APIError' do
      expect do
        raise described_class.new(resource: 'Test', message: 'Test error')
      end.to raise_error(Errors::APIError)
    end

    it 'can be raised and rescued as ResourceError' do
      expect do
        raise described_class.new(resource: 'Test', message: 'Test error')
      end.to raise_error(described_class, 'Test error')
    end

    it 'maintains inheritance chain' do
      error = described_class.new(resource: 'Test')
      expect(error.class.ancestors).to include(
        described_class,
        Errors::APIError,
        Errors::BaseError,
        StandardError
      )
    end
  end

  describe 'validation scenarios' do
    context 'typical validation error use case' do
      let(:validation_errors) do
        [
          'Name can\'t be blank',
          'Email has already been taken',
          'Password is too short (minimum is 6 characters)'
        ]
      end

      let(:error) do
        described_class.new(
          resource: 'User',
          message: validation_errors,
          detail: 'Please correct the following fields'
        )
      end

      it 'properly handles multiple validation errors' do
        expect(error.resource).to eq('User')
        expect(error.errors).to eq(validation_errors)
        expect(error.message).to eq(validation_errors.to_s)
        expect(error.detail).to eq('Please correct the following fields')
      end

      it 'includes validation errors as string in serialized hash' do
        hash = error.to_hash
        expect(hash[:resource]).to eq('User')
        expect(hash[:message]).to eq(validation_errors.to_s)
        expect(hash[:detail]).to eq('Please correct the following fields')
      end
    end

    context 'single error message use case' do
      let(:error) do
        described_class.new(
          resource: 'Product',
          message: 'Product not found',
          status: 404,
          code: 'product_not_found'
        )
      end

      it 'handles single error message properly' do
        expect(error.resource).to eq('Product')
        expect(error.errors).to eq(['Product not found'])
        expect(error.message).to eq('Product not found')
        expect(error.status).to eq(404)
      end
    end
  end

  describe 'integration with parent class methods' do
    let(:error) do
      described_class.new(
        resource: 'API',
        message: 'Service temporarily unavailable',
        status: 503,
        code: 'service_unavailable',
        detail: 'Please try again later'
      )
    end

    it 'to_hash merges parent hash with resource' do
      hash = error.to_hash

      expect(hash[:status]).to eq(503)
      expect(hash[:code]).to eq('service_unavailable')
      expect(hash[:message]).to eq('Service temporarily unavailable')
      expect(hash[:detail]).to eq('Please try again later')
      expect(hash[:resource]).to eq('API')
    end

    it 'maintains parent class behavior for JSON serialization' do
      hash = error.to_hash
      json_string = hash.to_json
      parsed = JSON.parse(json_string)

      expect(parsed['resource']).to eq('API')
      expect(parsed['status']).to eq(503)
      expect(parsed['message']).to eq('Service temporarily unavailable')
    end
  end

  describe 'required parameter validation' do
    it 'requires resource parameter' do
      expect do
        described_class.new(message: 'Test error')
      end.to raise_error(ArgumentError, /missing keyword: :resource/)
    end

    it 'accepts resource as only parameter' do
      expect do
        described_class.new(resource: 'MinimalTest')
      end.not_to raise_error
    end
  end
end
