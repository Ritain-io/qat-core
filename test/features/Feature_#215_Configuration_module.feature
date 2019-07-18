@epic#198 @feature#215 @config
Feature: Feature #215: Configuration module
  In order to manage environment configuration
  As a tester
  I want to choose which definitions to use

  Scenario: Load configuration folder with explicit path and environment
    When I load the "test-env2" environment from the "test_project/config" folder
    Then the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    And I have the values in the "test" configuration cache
      | foo | loaded_from             |
      | bar | variable_initialization |

  Scenario: Load configuration folder with explicit path and QAT_CONFIG_ENV environment variable
    Given I set the "QAT_CONFIG_ENV" environment variable with value "test-env3"
    When I load the "test_project/config" folder
    Then the loaded directory is "test_project/config"
    And the loaded environment is "test-env3"
    And I have the values in the "test" configuration cache
      | foo | loaded_from  |
      | bar | env_variable |

  Scenario: Load configuration folder with explicit path and using default YAML environment
    When I load the "test_project/config" folder
    Then the loaded directory is "test_project/config"
    And the loaded environment is "test-env1"
    And I have the values in the "test" configuration cache
      | foo | loaded_from  |
      | bar | default_yaml |

  Scenario: Load configuration folder with default path and using default YAML environment
    Given I change the current directory to "test_project/config"
    When I load the default folder
    Then the loaded directory is "test_project/config"
    And the loaded environment is "test-env1"
    And I have the values in the "test" configuration cache
      | foo | loaded_from  |
      | bar | default_yaml |

  Scenario: Load configuration folder with explicit path and using invalid YAML environment
    When I load the "test_project_invalid_conf/config" folder
    Then the loaded directory is "test_project_invalid_conf/config"
    And no environment is loaded
    And the cache is empty

  Scenario: Load configuration folder with explicit path and using empty YAML environment
    When I load the "test_project_empty_conf/config" folder
    Then the loaded directory is "test_project_empty_conf/config"
    And no environment is loaded
    And the cache is empty

  Scenario: Load configuration folder with explicit path and no default YAML in directory
    When I load the "test_project_no_default/config" folder
    Then the loaded directory is "test_project_no_default/config"
    And no environment is loaded
    And the cache is empty

  Scenario: Load configuration and change to valid directory
    Given I load the "test-env1" environment from the "test_project/config" folder
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env1"
    When I change the directory to "test_project_no_default/config"
    Then the loaded directory is "test_project_no_default/config"
    And the loaded environment is "test-env1"
    And I have the values in the "test" configuration cache
      | foo | loaded_from     |
      | bar | no_default_yaml |

  Scenario: Load configuration and change to invalid directory
    Given I load the "test-env2" environment from the "test_project/config" folder
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    When I change the directory to "invalid"
    Then a "ArgumentError" exception is raised
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    And I have the values in the "test" configuration cache
      | foo | loaded_from             |
      | bar | variable_initialization |

  Scenario: Load configuration and change to directory without original environment
    Given I load the "test-env2" environment from the "test_project/config" folder
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    When I change the directory to "test_project_no_default/config"
    Then the loaded directory is "test_project_no_default/config"
    And no environment is loaded
    And the cache is empty

  Scenario: Load configuration and change to nil directory
    Given I load the "test-env2" environment from the "test_project/config" folder
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    When I change the directory to "nil"
    Then a "ArgumentError" exception is raised
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    And I have the values in the "test" configuration cache
      | foo | loaded_from             |
      | bar | variable_initialization |


  Scenario: Load configuration and change to the same directory
    Given I load the "test-env2" environment from the "test_project/config" folder
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    When I change the directory to "test_project/config"
    Then the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    And I have the values in the "test" configuration cache
      | foo | loaded_from             |
      | bar | variable_initialization |


  Scenario: Load configuration and change environment
    Given I load the "test-env2" environment from the "test_project/config" folder
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    When I change the environment to "test-env3"
    Then the loaded directory is "test_project/config"
    And the loaded environment is "test-env3"
    And I have the values in the "test" configuration cache
      | foo | loaded_from  |
      | bar | env_variable |

  Scenario: Load configuration and change to invalid environment
    Given I load the "test-env2" environment from the "test_project/config" folder
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    When I change the environment to "invalid"
    Then a "QAT::Configuration::NoEnvironmentFolder" exception is raised
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    And I have the values in the "test" configuration cache
      | foo | loaded_from             |
      | bar | variable_initialization |

  Scenario: Load configuration and change to nil environment
    Given I load the "test-env2" environment from the "test_project/config" folder
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    When I change the environment to "nil"
    Then the loaded directory is "test_project/config"
    And no environment is loaded
    And the cache is empty

  Scenario: Common folder is loaded with environment definition
    Given I change the current directory to "test_project/config"
    When I load the default folder
    Then the loaded directory is "test_project/config"
    And the loaded environment is "test-env1"
    And I have the values in the "app1" configuration cache
      | name |
      | app1 |

  Scenario: List all environments in a directory
    When I load the "test_project/config" folder
    Then the environments list is
      | test-env1 |
      | test-env2 |
      | test-env3 |

  Scenario: Iterate through all environments without a loaded environment
    Given I load the "test_project_no_default/config" folder
    When I execute "['hosts']['test_host']['name']" through all environments
    Then the execution result list is
      | test2_dummy_host |
      | test3_dummy_host |
      | test1_host       |

  Scenario: Iterate through all environments with a loaded environment resets to original environment
    Given I load the "test_project/config" folder
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env1"
    When I execute ".environment" through all environments
    Then the execution result list is
      | test-env1 |
      | test-env2 |
      | test-env3 |
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env1"

  Scenario: Common definitions can be overloaded
    Given I load the "test_project/config" folder
    When I execute "['app1']['name']" through all environments
    Then the execution result list is
      | app1 |
      | app1 |
      | app2 |

  Scenario Outline: Indifferent access to keys - original key is string
    Given I load the "test_project/config" folder
    When I execute "<command>" in the current environment
    Then the execution result is "app2"
    Examples:
      | command          |
      | ['app2']['name'] |
      | ['app2'][:name]  |
      | [:app2]['name']  |
      | [:app2][:name]   |

  Scenario Outline: Indifferent access to keys - original key is symbol
    Given I load the "test_project/config" folder
    When I execute "<command>" in the current environment
    Then the execution result is "127.0.0.1"
    Examples:
      | command        |
      | ['app2']['ip'] |
      | ['app2'][:ip]  |
      | [:app2]['ip']  |
      | [:app2][:ip]   |

  Scenario: Cross reference from other file
    Given I load the "test_project/config" folder
    And I execute "[:app2][:name]" in the current environment
    And the execution result is "app2"
    And I execute "[:app3][:name]" in the current environment
    And the execution result is "app2"

  Scenario: Cross reference with indifferent access from other file
    Given I load the "test_project/config" folder
    And I execute "[:app2][:ip]" in the current environment
    And the execution result is "127.0.0.1"
    And I execute "[:app3][:ip]" in the current environment
    And the execution result is "127.0.0.1"

  Scenario: Cross reference to non existent value
    Given I load the "test_project/config" folder
    And I execute "[:app3][:no_ref]" in the current environment
    And the execution result is "app4.name"

  Scenario: Cached configurations cannot be edited in runtime
    Given I load the "test-env2" environment from the "test_project/config" folder
    And the loaded directory is "test_project/config"
    And the loaded environment is "test-env2"
    And I have the values in the "test" configuration cache
      | foo | loaded_from             |
      | bar | variable_initialization |
    When I try to edit the value at "test.foo" to "baz"
    And the cached value at "test.foo" is still "bar"
