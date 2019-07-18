@user_story#20
Feature: Deep compact
  As a user,
  In order to remove nil values from complex structures (nested Hashes/Arrays),
  I want to have a method that removes those nil values throughout the structure tree

  Scenario Outline: Non-destructively deep compact a hash
    Given a hash defined as "<initial_object>"
    When the method "deep_compact" is call on the existing hash
    Then the new hash is "<result_object>"
    And the existing hash remains unchanged

    Examples:
      | initial_object                                                     | result_object                           |
      | {}                                                                 | {}                                      |
      | { a: nil, b: nil }                                                 | {}                                      |
      | { a: nil, b: 'b' }                                                 | { b: 'b' }                              |
      | { a: nil, b: { ba: 'ba', bb: { bba: nil, bbb: 'bbb' }, bc: nil } } | { b: { ba: 'ba', bb: { bbb: 'bbb' } } } |
      | { a: nil, b: 'value', c: [1, 2, 3] }                               | { b: 'value', c: [1, 2, 3] }            |
      | { a: nil, b: 'value', c: [1, nil, { ca: 3, cb: nil }] }            | { b: 'value', c: [1, { ca: 3 }] }       |


  Scenario Outline: Destructively deep compact a hash
    Given a hash defined as "<initial_object>"
    When the method "deep_compact!" is call on the existing hash
    Then the hash is "<result_object>"

    Examples:
      | initial_object                                                     | result_object                           |
      | {}                                                                 | {}                                      |
      | { a: nil, b: nil }                                                 | {}                                      |
      | { a: nil, b: 'b' }                                                 | { b: 'b' }                              |
      | { a: nil, b: { ba: 'ba', bb: { bba: nil, bbb: 'bbb' }, bc: nil } } | { b: { ba: 'ba', bb: { bbb: 'bbb' } } } |
      | { a: nil, b: 'value', c: [1, 2, 3] }                               | { b: 'value', c: [1, 2, 3] }            |
      | { a: nil, b: 'value', c: [1, nil, { ca: 3, cb: nil }] }            | { b: 'value', c: [1, { ca: 3 }] }       |


  Scenario Outline: Non-destructively deep compact an array
    Given an array defined as "<initial_object>"
    When the method "deep_compact" is call on the existing array
    Then the new array is "<result_object>"
    And the existing array remains unchanged

    Examples:
      | initial_object                                    | result_object                   |
      | []                                                | []                              |
      | [nil, nil]                                        | []                              |
      | [nil, 'b']                                        | ['b']                           |
      | [nil, ['ba', [nil, 'bbb'], nil], 'c']             | [['ba', ['bbb']], 'c']          |
      | [nil, 'value', { c: [1, 2, 3] }]                  | ['value', { c: [1, 2, 3] }]     |
      | [nil, 'value', { c: [1, nil, { d: 3, e: nil }] }] | ['value', { c: [1, { d: 3 }] }] |


  Scenario Outline: Destructively deep compact an array
    Given an array defined as "<initial_object>"
    When the method "deep_compact!" is call on the existing array
    Then the array is "<result_object>"

    Examples:
      | initial_object                                    | result_object                   |
      | []                                                | []                              |
      | [nil, nil]                                        | []                              |
      | [nil, 'b']                                        | ['b']                           |
      | [nil, ['ba', [nil, 'bbb'], nil], 'c']             | [['ba', ['bbb']], 'c']          |
      | [nil, 'value', { c: [1, 2, 3] }]                  | ['value', { c: [1, 2, 3] }]     |
      | [nil, 'value', { c: [1, nil, { d: 3, e: nil }] }] | ['value', { c: [1, { d: 3 }] }] |