@us#11 @announce
Feature: User Story #11: Generate Random Integers

  Scenario: Generate a default random integer
    When I generate a random integer
    Then the generated integer has length 1

  Scenario Outline: Generate a random integer with a given length
    When I generate a random integer with length <size>
    Then the generated integer has length <size>

    Examples:
      | size |
      | 5    |
      | 32   |
      | 143  |

  Scenario Outline: Generate a random integer with invalid argument
    When I generate a random integer with argument "<argument>"
    Then a "ArgumentError" exception is raised
    And the exception reads "Argument should be an Integer!"

    Examples:
      | argument |
      | 'abcde'  |
      | { a: 1}  |
      | [1,2,:a] |
      | Integer  |