# frozen_string_literal: true

require_relative '../../helpers/spec_helper'

describe 'Unit test of Result value' do
  it 'should return valid success status and message' do
    result = YouFind::Response::ApiResult.new(status: :ok, message: 'foo')

    _(result.status).must_equal :ok
    _(result.message).must_equal 'foo'
  end

  it 'should show valid failure status and message' do
    result = YouFind::Response::ApiResult.new(status: :not_found, message: 'foo')

    _(result.status).must_equal :not_found
    _(result.message).must_equal 'foo'
  end

  it 'should report error for invalid status' do
    _(proc do
      YouFind::Response::ApiResult.new(status: :foobar, message: 'foo')
    end).must_raise ArgumentError
  end
end
