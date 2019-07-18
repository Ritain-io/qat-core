# -*- encoding : utf-8 -*-
require 'forwardable'
require 'singleton'
require_relative 'core/version'

module QAT
  #Core shared memory class. Works as a singleton.
  #
  #Apart from a regular shared cache class with CRUD operations, it also has a reset functionality,
  #allowing to define exception values that will never be reset.
  #
  #@since 0.1.0
  class Core
    include Singleton
    extend Forwardable

    def_delegators :@storage, :[], :[]=, :store, :delete

    def initialize
      @storage    = {}
      @exceptions = []
    end

    #Makes a key permanent in the cache, so that it won't deleted when {#reset!} is called.
    #@param [Object] key Key to make permanent
    #@see #reset!
    def make_permanent key
      @exceptions << key unless @exceptions.include? key
    end


    #Stores value to the given key and marks key as permanent, so that it won't deleted when {#reset!} is called.
    #@param [Object] key Key to make permanent
    #@param [Object] value Value to store in cache
    #@see #reset!
    def store_permanently key, value
      make_permanent key
      store key, value
    end

    #Deletes all keys not maked as permanent from the cache.
    #@since 0.1.0
    def reset!
      @storage.select! { |key, _| @exceptions.include?(key) }
    end
  end

  class << self
    extend Forwardable
    def_delegators :'QAT::Core.instance', *(QAT::Core.public_instance_methods - Object.public_instance_methods)
  end

end