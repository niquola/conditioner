$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Conditioner
  VERSION = '0.0.1'
  autoload :ActiveRecordMixin, 'conditioner/active_record_mixin'
  autoload :Condition, 'conditioner/condition'

  class << self
    def enable
      ActiveRecord::Base.send :extend, ActiveRecordMixin
    end

    def condition(table_name,fields)
    end
  end
end

if defined? Rails
  Conditioner.enable if defined? ActiveRecord
end
