# frozen_string_literal: true

require_relative '../test_helper'

module REST
  class ResponseTest < REST::Test
    test 'initializes without a body' do
      response = Response.new(404)
      assert_equal 404, response.status_code
      assert_equal '', response.body
    end

    test 'responds to all the status code names' do
      response = Response.new(200)
      Response::CODES.to_h.each_value do |name|
        assert_respond_to response, "#{name}?"
      end
    end

    test 'knows if the request was a success' do
      refute Response.new(422).success?
      assert Response.new(201).success?
      assert Response.new(202).success?
    end

    test 'has working boolean methods for status codes' do
      response = Response.new(422)
      refute response.ok?
      refute response.not_found?
      assert response.unprocessable_entity?
    end
  end
end
