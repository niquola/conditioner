module Conditioner
  class FakeModel

    def initialize(table_name, options = {})
      @table_name = table_name
      @options = options
    end

    def sanitize_sql_for_conditions(*args)
      args << ActiveRecord::Base.connection.quote_table_name(@table_name)
      ActiveRecord::Base.send(:sanitize_sql_for_conditions, *args)
    end

    def column_names
      if @options[:columns]
        @options[:columns]
      else
        @column_names ||= ActiveRecord::Base.connection.columns(@table_name).map { |c| c.name }
      end
    end

    def table_name
      @table_name
    end

  end
end
