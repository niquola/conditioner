module Conditioner
  class Condition < String
    def initialize(model)
      @model=model
      @result=[]
      @column_names=@model.column_names
      @first_condition=true
      yield self if block_given?
    end

    def and(*args)
      add_condition('AND',*args)
    end

    def _and(*args)
      add_condition('AND',*args)
    end

    def or(*args)
      add_condition('OR',*args)
    end

    def _or(*args)
      add_condition('OR',*args)
    end

    def add_condition(unit,*args)
      @condition_called_flag= true
      result= []
      unless @first_condition
        result<<' '<<unit
      else
        @first_condition=false
      end
      result<<@model.send(:sanitize_sql_for_conditions, *args)
      self<< result.join(" ")
      self
    end

    def is_field?(field)
      @column_names.include?(field)
    end

    def with_table_name(field_name)
      %Q[#{@model.table_name}.#{field_name}]
    end

    def extract(hash)
      hash.each do |k,v|
        field = k.to_s
        Conditioner.config.extract_rules.each do |rule|
          rule.call(field,v,self)
          break if @condition_called_flag
        end
        _and(field=>v) if is_field?(field) and !@condition_called_flag
        @condition_called_flag = false
      end
      self
    end
  end
end
