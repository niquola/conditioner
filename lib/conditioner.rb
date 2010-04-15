$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Conditioner
  VERSION = '0.0.3'
  autoload :ActiveRecordMixin, 'conditioner/active_record_mixin'
  autoload :Condition, 'conditioner/condition'
  autoload :Configurator, 'conditioner/configurator'

  class << self
    def enable
      ActiveRecord::Base.send :extend, ActiveRecordMixin
      Conditioner.config.activate_default_rules!
    end

    def condition(table_name,fields)
    end

    def config
      @config ||= Configurator.new
    end

    def configure
      yield config
    end
  end
end

if defined? Rails
  Conditioner.enable if defined? ActiveRecord
end
