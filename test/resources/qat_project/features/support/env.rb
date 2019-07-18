# Code coverage
require 'simplecov'
require 'qat/configuration'
require 'minitest'

module Test
  include Minitest::Assertions

  attr_writer :assertions

  def assertions
    @assertions ||= 0
  end
end
World(Test)
