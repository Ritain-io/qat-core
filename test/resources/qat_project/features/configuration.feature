@configuration
Feature: configuration tests

  Scenario: Access variable
    When I access the value of "foo" in "env" yml file
    Then the value is "bar"

  Scenario: Access environment value
    When I access the value of the environment name
    Then the value is "dummy"
