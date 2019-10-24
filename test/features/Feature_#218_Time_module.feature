@epic#198 @feature#218 @time
Feature: Feature #218: Time module
  In order to test case sensitive scenarios
  As a tester
  I want to manipulate the test's clock

  Background: Time is stopped during tests
    Given I freeze the clock

  Scenario: Synchronize clock using NTP
    When I synchronize the clock with host "test host" using "NTP"
    Then no exception is raised

  Scenario: Synchronize clock using SSH
    When I synchronize the clock with host "test host" using "SSH"
    Then no exception is raised

  Scenario Outline: Default method exists to use synchronization
    When I synchronize the clock with host "localhost" using "<type>"
    Then no exception is raised
    Examples:
      | type |
      | NTP  |
      | SSH  |

  Scenario: Synchronization returns current time
    When I synchronize the clock with host "localhost"
    Then the synchronization result is the current time

  Scenario: Synchronization methods can be defined
    When I synchronize the clock with host "pool.ntp.org" using "TestMethod"
    Then a "NotImplementedError" exception is raised
    Given I create a dummy method for "TestMethod" synchronization
    When I synchronize the clock with host "pool.ntp.org" using "TestMethod"
    Then no exception is raised
    And the dummy method was executed

  Scenario Outline: Clock changes on synchronization
    Given I create a synchronization method to <modification>
    When I synchronize the clock with host "pool.ntp.org"
    Then no exception is raised
    And the dummy method was executed
    And the result clock value is correct
    Examples:
      | modification      |
      | advance 2 hours   |
      | go back 5 minutes |
      | advance 3 weeks   |

  Scenario Outline: Synchronization methods must have 3 parameters
    When I create a synchronization method with "<num>" parameters
    Then <error> exception is raised
    Examples:
      | num | error             |
      | 0   | a "ArgumentError" |
      | 1   | a "ArgumentError" |
      | 2   | a "ArgumentError" |
      | 3   | no                |
      | 4   | a "ArgumentError" |
      | 5   | a "ArgumentError" |

  Scenario: Synchronization with localhost returns original time
    When I synchronize the clock with host "localhost"
    Then the synchronization result has initial clock
    And the synchronization result has initial time zone

  Scenario: Synchronization with localhost does not execute method
    Given I create a dummy method for "TestMethod" synchronization
    When I synchronize the clock with host "localhost" using "TestMethod"
    Then the dummy method was not executed

  Scenario: Time zone can be set
    When I set the current time zone to "Madrid"
    And I get the current time
    Then the result clock value is correct
    And the result time zone is "Madrid"

  Scenario: There is always a default time zone
    When I set the current time zone to "nil"
    And I get the current time
    Then the result clock value is correct
   # And the result time zone is the local zone

  Scenario Outline: Parsing of natural language time representation
    When I set the current time zone to "nil"
    When I parse the time string "<time>"
    Then the result clock is expected to <modification>
    #And the result time zone is the local zone
    Examples:
      | time             | modification      |
      | in 24 hours      | advance 1 day     |
      | five minutes ago | go back 5 minutes |
      | now              | advance 0 minutes |

  Scenario: Parsing of natural language time representation with different time zone
    When I set the current time zone to "Madrid"
    When I parse the time string "now"
    Then the result clock is expected to advance 0 minutes
    And the result time zone is "Madrid"