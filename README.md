[![Build Status](https://travis-ci.org/readiness-it/qat-core.svg?branch=master)](https://travis-ci.org/readiness-it/qat-core)

# QAT::Core

- Welcome to the QAT Core gem!

## Table of contents 
- This gem is a set of the following capabilities: 
  - **Shared memory for objects;**
  - **Environments configuration manager;**
  - **Time modification and enhancement;**
  - **Other utilities;**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'qat-core'
```

And then execute:

    $ bundle install

Or install it manually:

    $ gem install qat-core
    
# Usage
## Shared memory for objects:

This module allows caching of certain valued objects, either permanently or in a way that a periodic cleaning can be done

 

## Manage environments configuration:
In order to load/manage configurations it is necessary to have the following folder configuration example:

```
project   
└───config
│   └───common
│   |    │ app1.yml
│   |    │ app2.yml
│   |    │ ...
│   |
|   └───env1
|   |    │ databases.yml
|   |    │ hosts.yml
|   |    │ test.yml
|   |    │ ...
|   |    |
|   |    |
|   |   env2
|   |   env3
|   |   ...
|   |    
|  cucumber.yml
|  default.yml
   

```
###Set an environment
To set your default environment use the ```default.yml```:

```env: 'env1'```

Or use the ```QAT_CONFIG_ENV``` environment variable(Please note that this variable overrides ```default.yml```)

```
QAT_CONFIG_ENV = 'env2'
```

##Time modification and enhancement
This module features are:
 - Clock Synchronization
 - Time Zone modification


##Other utilities
This gem also contains 3 very useful utilities:
 - Complex hash manipulator
 - IP Validator
  - Random integer generator

# Documentation

- [API documentation](https://readiness-it.github.io/qat-core/doc/index.html)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/readiness-it/qat-core. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the QAT::Core project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/readiness-it/qat-core/blob/master/CODE_OF_CONDUCT.md).