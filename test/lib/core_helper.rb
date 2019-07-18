module CoreHelper
  attr_accessor :core_target

  def core_target
    @core_target ||= QAT::Core.instance
  end

  def default_key
    'test'
  end
end

World CoreHelper