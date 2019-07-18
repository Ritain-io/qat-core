@story#5 @config
Feature: Load files from nested configuration folders
  In order to have better configuration file organization
  As a configuration manager
  I want to load configuration files nested in folders

  Scenario: Load configuration folder with nested configurations
    Given I change the current directory to "test_project_nested/config"
    When I load the default folder
    Then the loaded directory is "test_project_nested/config"
    And the loaded environment is "test-env1"
    And I have the values in the "test" configuration cache
      | foo | loaded_from  | from_nested_common | from_nested_env |
      | bar | default_yaml | app1               | 1.0             |


  Scenario: Nested configurations are correctly merged with common
    Given I change the current directory to "test_project_nested/config"
    When I load the default folder
    Then the loaded directory is "test_project_nested/config"
    And the loaded environment is "test-env1"
    And I have the values in the "app2.config" configuration cache
      | name | version | value                        |
      | app2 | 2.0     | this is environment specific |


  Scenario: A file exist in the root folder with the same name as one folder
    When I load the "test-env1" environment from the "test_project_nested_invalid/config" folder
    Then a "QAT::Configuration::InvalidFolderName" exception is raised
    And the exception reads "A file with name app1 exists and was already loaded!"


  Scenario: A file exist in a nested folder with the same name as sibling folder
    When I load the "test-env2" environment from the "test_project_nested_invalid/config" folder
    Then a "QAT::Configuration::InvalidFolderName" exception is raised
    And the exception reads "A file with name child exists and was already loaded!"


  Scenario: Configuration are correctly intersected from nested configuration
    Given I change the current directory to "test_project_nested/config"
    When I load the default folder
    Then the loaded directory is "test_project_nested/config"
    And the loaded environment is "test-env1"
    And I have the values in the "app1.config" configuration cache
      | name | version | host       | connects_with.name | connects_with.version |
      | app1 | 1.0     | 172.16.0.1 | app3_child         | 3.0                   |