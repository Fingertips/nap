# frozen_string_literal: true

require_relative '../test_helper'

module REST
  class ErrorTest < REST::Test
    test 'extends any Timeout related exception' do
      classes = Error::Timeout.classes
      refute_empty classes
      classes.each do |error_class|
        assert_raises(Error::Timeout) { raise error_class }
        assert_raises(Error) { raise error_class }
      end
    end

    test 'extends any Connection related exception' do
      classes = Error::Connection.classes
      refute_empty classes
      classes.each do |error_class|
        assert_raises(Error::Connection) { raise error_class }
        assert_raises(Error) { raise error_class }
      end
    end

    test 'extends any Protocol related exception' do
      classes = Error::Protocol.classes
      refute_empty classes
      classes.each do |error_class|
        assert_raises(Error::Protocol) { raise error_class }
        assert_raises(Error) { raise error_class }
      end
    end
  end
end
