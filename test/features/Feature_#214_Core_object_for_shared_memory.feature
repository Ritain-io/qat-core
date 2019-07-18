@epic#198 @feature#214 @core
Feature: Feature #214: Core instance for shared memory
  In order to integrate various plugins
  As a developer
  I want to have a shared memory

  Background: The shared memory is clear

  Scenario: Save an object in the shared memory with the store method
    Given I have no object saved
    When I save an object using the "store" method
    Then I have the original object saved

  Scenario: Save an object in the shared memory with the []= method
    Given I have no object saved
    When I save an object using the "[]=" method
    Then I have the original object saved

  Scenario: Save an object in the shared memory with the store permanently method
    Given I have no object saved
    When I save an object using the "store_permanently" method
    Then I have the original object saved

  Scenario: Delete an object in the shared memory
    Given I have no object saved
    And I save an object using the "[]=" method
    And I have the original object saved
    When I delete the object saved
    Then I have no object saved

  Scenario: Keys can be reset
    Given I save an object using the "store" method
    And I have the original object saved
    When I reset the Core instance
    Then I have no object saved

  Scenario: Permanent keys can not be reset
    Given I save an object using the "store_permanently" method
    And I have the original object saved
    When I reset the Core instance
    And I have the original object saved

  Scenario: Only permanent keys can not be reset
    Given I save an object with key "not permanent" using the "store" method
    And I have the original object saved in key "not permanent"
    And I save an object with key "permanent" using the "store_permanently" method
    And I have the last object saved in key "permanent"
    When I reset the Core instance
    Then I have no object saved in key "not permanent"
    And I have the last object saved in key "permanent"

  Scenario: Reassignment of permanet key saves the last value
    Given I save an object using the "store_permanently" method
    And I have the original object saved
    And I delete the object saved
    And I have no object saved
    When I save an object using the "[]=" method
    And I reset the Core instance
    Then I have the last object saved

  Scenario: Make old key permanent
    Given I save an object using the "store" method
    And I have the original object saved
    When I make the key permanent
    And I reset the Core instance
    Then I have the original object saved

  Scenario: Make old key permanent
    Given I save an object using the "store" method
    And I have the original object saved
    When I make the key permanent
    And I reset the Core instance
    Then I have the original object saved

  Scenario: Can access all Core instance methods in QAT module proxy
    Given I am using the QAT proxy for the Core singleton
    When I save an object with key "not permanent" using the "store" method
    And I have the original object saved in key "not permanent"
    And I save an object with key "permanent" using the "store_permanently" method
    And I have the last object saved in key "permanent"
    And I reset the Core instance
    Then I have no object saved in key "not permanent"
    And I have the last object saved in key "permanent"
    When I save an object with key "will be permanent" using the "[]=" method
    And I have the last object saved in key "will be permanent"
    And I make the key "will be permanent" permanent
    And I reset the Core instance
    Then I have the last object saved in key "will be permanent"
