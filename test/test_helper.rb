require 'stringio'
require File.dirname(__FILE__) + '/../lib/conditioner'
require 'rubygems'
require "test/unit"
require 'active_record'

ActiveRecord::Base.logger = nil
class TestUtils
  class<< self
    def config
      {
        :adapter=>'postgresql',
        :host=> 'localhost',
        :database=>'unittest_conditioner',
        :username=>'postgres',
        :password=>'postgres',
        :encoding=>'utf8'
      }
    end

    #create test database
    def ensure_test_database
      connect_to_test_db
    rescue
      create_database
    end

    def create_database
      connect_to_postgres_db
      ActiveRecord::Base.connection.create_database(config[:database], config)
      connect_to_test_db
    rescue
      $stderr.puts $!, *($!.backtrace)
      $stderr.puts "Couldn't create database for #{config.inspect}"
    end

    def connect_to_test_db
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Base.connection
    end

    def connect_to_postgres_db
      ActiveRecord::Base.establish_connection(config.merge(:database => 'postgres', :schema_search_path => 'public'))
    end

    def drop_database
      connect_to_postgres_db
      ActiveRecord::Base.connection.drop_database config[:database]
    end
  end
end

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :last_name,                 :limit => 25
      t.string   :first_name,                :limit => 25
      t.string   :middle_name,               :limit => 25
      t.string   :name,                      :limit => 25
      t.string   :login,                     :limit => 40
      t.string   :email,                     :limit => 100
      t.string   :crypted_password,          :limit => 40
      t.string   :salt,                      :limit => 40
      t.datetime :last_login_datetime
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

Conditioner.enable

class User< ActiveRecord::Base
end

TestUtils.ensure_test_database
CreateUsers.migrate(:up) unless ActiveRecord::Base.connection.table_exists?('users')
#CreateUsers.migrate :down
