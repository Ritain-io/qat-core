@assertions
Feature: true assertion tests

  Scenario: true
    When true
    Then true

  Scenario Outline: Many trues
    When <true>
    Then <true>

  Examples:
    | true |
    | true |
    | true |

