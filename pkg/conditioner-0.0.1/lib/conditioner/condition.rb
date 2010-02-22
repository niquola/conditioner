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
      @column_names.include?(field.to_s) || (field.to_s =~ /^(from|to)_(\w*_(datetime|at))/ && @column_names.include?($2))
    end

    def c(field_name)
      %Q[#{@model.table_name}.#{field_name}]
    end

    #FIXME: document conventions
    #add more conventions like
    #name_start_from
    #field_end_with
    #field_in_range
    #field_gt
    #field_mt
    def extract(hash)
      hash.each do |k,v|
        next unless is_field?(k)
        if v =~ /(\*$|^\*)/
          _and(["#{c(k)} ILIKE ?",v.gsub(/(\*$|^\*)/,'%')])
        elsif v =~ /(%$|^%)/
          _and(["upper(#{c(k)}) like upper(?)",v])
          #FIXME: add logic for ranges
        elsif k.to_s =~ /^from_(\w*_(datetime|at))/
          _and(["#{c($1)} >= ?","#{v} 00:00:00.000"])
        elsif k.to_s =~ /^to_(\w*_(datetime|at))/
          _and(["#{c($1)} <= ?","#{v} 23:59:59.999"])
        elsif k.to_s.include?('_datetime') || k.to_s.include?('_at')
          _and(["(#{c(k)} BETWEEN ? AND ?)","#{v} 00:00","#{v} 23:59:59.999"])
        else
          _and(k=>v)
        end
      end
      self
    end
  end
end
