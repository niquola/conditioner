module Conditioner
  class Configurator

    def extract_rules
      @rules ||= []
    end

    def add_rule(&rule)
      extract_rules<< rule
    end

    #You can clear default rules with
    def clear_rules!
      @rules = []
    end

    def activate_default_rules!
      add_rule do |field, v, cnd|
        unless v.nil? || (v.respond_to?(:'empty?') && v.empty?)
          if cnd.is_field?(field) && v =~ /(\*$|^\*)/
            cnd.and(["#{cnd.with_table_name(field)} ILIKE ?",v.gsub(/(\*$|^\*)/,'%')])
          elsif cnd.is_field?(field) && v =~ /(%$|^%)/
            cnd.and(["upper(#{cnd.with_table_name(field)}) like upper(?)",v])
            #FIXME: add logic for ranges
          elsif field=~ /^from_(\w*_(datetime|at))/ and cnd.is_field?($1)
            cnd.and(["#{cnd.with_table_name($1)} >= ?","#{v} 00:00:00.000"])
          elsif field=~ /^to_(\w*_(datetime|at))/ and cnd.is_field?($1)
            cnd.and(["#{cnd.with_table_name($1)} <= ?","#{v} 23:59:59.999"])
          elsif cnd.is_field?(field) && (field.include?('_datetime') || field.include?('_at'))
            cnd.and(["(#{cnd.with_table_name(field)} BETWEEN ? AND ?)","#{v} 00:00","#{v} 23:59:59.999"])
          elsif field=~ /^(\w*)_(ltoe|gtoe|lt|gt)$/ and cnd.is_field?($1)
            operator = { 'lt' => '<', 'gt' => '>', 'ltoe' => '<=', 'gtoe' => '>=' }[$2]
            cnd.and(["#{cnd.with_table_name($1)} #{operator} ?", v])
          elsif field=~ /^(\w*)_(begins_with|ends_with|contains)$/ and cnd.is_field?($1)
            if $2 == 'begins_with'
              like_expr = "#{v}%"
            elsif $2 == 'ends_with'
              like_expr = "%#{v}"
            else
              like_expr = "%#{v}%"
            end
            cnd.and(["#{cnd.with_table_name($1)} ILIKE ?", like_expr])
          elsif field=~ /^(\w*)_in$/ and cnd.is_field?($1)
            cnd.and(["#{cnd.with_table_name($1)} IN (?)", v])
          end
        end
      end
    end
  end
end
