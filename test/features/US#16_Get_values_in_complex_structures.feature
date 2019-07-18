@navigate_path
Feature: Get values in complex structures for a given path

  Background:
    Given a complex structure:
    """
    {
      'root' => {
        'leaf1' => {
          'leaf11' => {
            'key111' => 'value111',
            'key112' => 'value112'
          },
          'key12' => 'value12'
        },
        'leaf2' => [
          'leaf21' => {
            'key211' => 'value211',
            'key212' => 'value212'
          },
          'leaf22' => {
            'key221' => 'value221',
            'key222' => 'value222'
          }
        ],
        'leaf3' => [
          'value31',
          'value32',
          'value33'
        ]
      },
      'root_key' => 'root_value'
    }
    """


  Scenario: Get a value from a simple path
    When the value from path "root.leaf1.leaf11.key111" is obtained
    Then the obtained value is "value111"


  Scenario: Get a value from a complex path
    When the value from path "root.leaf2.[*].leaf21.key211" is obtained
    Then the obtained value is "value211"


  Scenario: Get multiple values from a simple path
    When the value from path "root.leaf3" is obtained
    Then the obtained values are:
      | values  |
      | value31 |
      | value32 |
      | value33 |

  Scenario: Get a value from root level
    When the value from path "root_key" is obtained
    Then the obtained value is "root_value"