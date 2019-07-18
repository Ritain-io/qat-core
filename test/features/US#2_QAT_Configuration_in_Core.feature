@us#2 @announce
Feature: User Story #2: Have shortcut to Configuration in qat-core

  Background: Create QAT project
    Given I copy the directory named "../../resources/qat_project" to "project"
    And I cd to "project"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |

  Scenario: Run dummy QAT project that requires a QAT World's assertions to work
    When I run `rake assertions_tests`
    Then the exit status should be 0

  Scenario: Run dummy QAT project that uses configuration to work
    When I run `rake configuration_tests`
    Then the exit status should be 0