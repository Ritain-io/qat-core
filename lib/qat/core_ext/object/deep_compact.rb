require 'active_support/core_ext/object/deep_dup'
require 'active_support/core_ext/hash/compact'

# class Hash
class Hash
  # Returns a copy of the current hash with non nil values throughout all tree
  #@return [Hash]
  #
  # @example
  #  > hash = {a: nil, b: 'b'}
  #  > hash.deep_compact
  #  => {b: 'b'}
  #  > hash
  #  => {a: nil, b: 'b'}
  #
  #  > hash = { a: nil, b: { ba: 'ba', bb: { bba: nil, bbb: 'bbb' }, bc: nil } }
  #  > hash.deep_compact
  #  => { b: { ba: 'ba', bb: { bbb: 'bbb' } } }
  #  > hash
  #  => { a: nil, b: { ba: 'ba', bb: { bba: nil, bbb: 'bbb' }, bc: nil } }
  #
  #  > hash = { a: nil, b: 'value', c: [1, 2, 3] }
  #  > hash.deep_compact
  #  => { b: 'value', c: [1, 2, 3] }
  #  > hash
  #  => { a: nil, b: 'value', c: [1, 2, 3] }
  #
  #  > hash = { a: nil, b: 'value', c: [1, nil, { ca: 3, cb: nil }] }
  #  > hash.deep_compact
  #  => { b: 'value', c: [1, { ca: 3 }] }
  #  > hash
  #  => { a: nil, b: 'value', c: [1, nil, { ca: 3, cb: nil }] }
  #
  def deep_compact
    deep_dup.deep_compact!
  end


  # Replaces the current hash with non nil values throughout all tree
  #@return [Hash]
  #
  # @example
  #  > hash = {a: nil, b: 'b'}
  #  > hash.deep_compact!
  #  => {b: 'b'}
  #  > hash
  #  => {b: 'b'}
  #
  #  > hash = { a: nil, b: { ba: 'ba', bb: { bba: nil, bbb: 'bbb' }, bc: nil } }
  #  > hash.deep_compact!
  #  => { b: { ba: 'ba', bb: { bbb: 'bbb' } } }
  #  > hash
  #  => { b: { ba: 'ba', bb: { bbb: 'bbb' } } }
  #
  #  > hash = { a: nil, b: 'value', c: [1, 2, 3] }
  #  > hash.deep_compact!
  #  => { b: 'value', c: [1, 2, 3] }
  #  > hash
  #  => { b: 'value', c: [1, 2, 3] }
  #
  #  > hash = { a: nil, b: 'value', c: [1, nil, { ca: 3, cb: nil }] }
  #  > hash.deep_compact!
  #  => { b: 'value', c: [1, { ca: 3 }] }
  #  > hash
  #  => { b: 'value', c: [1, { ca: 3 }] }
  #
  def deep_compact!
    self.compact!
    self.each do |key, value|
      self[key] = value.respond_to?(:deep_compact!) ? value.deep_compact! : value
    end
  end
end

# class Array
class Array
  # Returns a copy of the the current array with non nil values throughout all tree
  #@return [Array]
  #
  # @example
  #  > array = [nil, 'b']
  #  > array.deep_compact!
  #  => ['b']
  #  > array
  #  => [nil, 'b']
  #
  #  > array = [nil, ['ba', [nil, 'bbb'], nil], 'c']
  #  > array.deep_compact!
  #  => [['ba', ['bbb']], 'c']
  #  > array
  #  => [nil, ['ba', [nil, 'bbb'], nil], 'c']
  #
  #  > array = [nil, 'value', { c: [1, 2, 3] }]
  #  > array.deep_compact!
  #  => ['value', { c: [1, 2, 3] }]
  #  > array
  #  => [nil, 'value', { c: [1, 2, 3] }]
  #
  #  > array = [nil, 'value', { c: [1, nil, { d: 3, e: nil }] }]
  #  > array.deep_compact!
  #  => ['value', { c: [1, { d: 3 }] }]
  #  > array
  #  => [nil, 'value', { c: [1, nil, { d: 3, e: nil }] }]
  #
  def deep_compact
    deep_dup.deep_compact!
  end


  # Replaces the current array with non nil values throughout all tree
  #@return [Array]
  #
  # @example
  #  > array = [nil, 'b']
  #  > array.deep_compact!
  #  => ['b']
  #  > array
  #  => ['b']
  #
  #  > array = [nil, ['ba', [nil, 'bbb'], nil], 'c']
  #  > array.deep_compact!
  #  => [['ba', ['bbb']], 'c']
  #  > array
  #  => [['ba', ['bbb']], 'c']
  #
  #  > array = [nil, 'value', { c: [1, 2, 3] }]
  #  > array.deep_compact!
  #  => ['value', { c: [1, 2, 3] }]
  #  > array
  #  => ['value', { c: [1, 2, 3] }]
  #
  #  > array = [nil, 'value', { c: [1, nil, { d: 3, e: nil }] }]
  #  > array.deep_compact!
  #  => ['value', { c: [1, { d: 3 }] }]
  #  > array
  #  => ['value', { c: [1, { d: 3 }] }]
  #
  def deep_compact!
    self.compact!
    self.map! do |element|
      element.respond_to?(:deep_compact!) ? element.deep_compact! : element
    end
  end
end