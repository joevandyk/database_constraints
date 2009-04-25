ENV['RAILS_ENV'] = 'test'

require 'test/unit'
require 'rubygems'
require 'active_record'
require 'database_constraints'
require 'foreign_keys'

begin
  require 'redgreen'
rescue LoadError
end

connection = { :adapter => 'postgresql', :database => 'database_constraints' }
ActiveRecord::Base.establish_connection(connection)
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')

require File.dirname(__FILE__) + '/schema'
require File.dirname(__FILE__) + '/models'