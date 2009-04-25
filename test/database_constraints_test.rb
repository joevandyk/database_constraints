ENV['RAILS_ENV'] = 'test'

require 'test/unit'
require 'rubygems'
require 'active_record'
require 'database_constraints'

# Establish connection to PostgreSQL +database_constraints+ database.
ActiveRecord::Base.establish_connection :adapter => 'postgresql', 
                                        :database => 'database_constraints'

ActiveRecord::Migration.verbose = false

# Migrations.
class CreateTables < ActiveRecord::Migration

  def self.up

    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :login
    end

    create_table :posts do |t|
      t.string :title
      t.text :body
    end

    create_table :products do |t|
      t.string :name
      t.integer :price
    end

  end

  def self.down
    drop_table :users
    drop_table :posts
    drop_table :products
  end

end

# Define models.
class User < ActiveRecord::Base; end
class Post < ActiveRecord::Base; end
class Product < ActiveRecord::Base; end

##
# Here we go with the tests ...
#
class DatabaseConstraintsTest < Test::Unit::TestCase

  def setup
    CreateTables.up
  end

  def teardown
    CreateTables.down
  end

  def test_should_add_email_check

    ActiveRecord::Migration.add_email_check :users, :email

    valid_emails = %w( john@example.com john@example.co.uk john@example.es )
    valid_emails.each do |email|
      User.create :email => email
    end
    assert_equal valid_emails.size, User.count

    %w( invalid@email invalid invalid.com invalid@DEMO.COM invalid@DEMO.com INVALID@example.com ).each do |email|

      begin
        User.create :email => email
      rescue Exception => error
        assert_match /PGError/, error.message
        assert_match /violates check constraint "valid_email"/, error.message
      end

    end

  end

  def test_should_add_login_check

    ActiveRecord::Migration.add_login_check :users, :login

    valid_logins = [ 'abcd', 'ABCD', '1234567890' ]
    valid_logins.each do |login|
      User.create :login => login
    end
    assert_equal valid_logins.size, User.count

    [ '-', '?', '+', '_' ].each do |login|

      begin
        User.create :login => login
      rescue Exception => error
        assert_match /PGError/, error.message
        assert_match /violates check constraint "valid_login"/, error.message
      end

    end

  end

  def test_should_add_uniqueness_check

    ActiveRecord::Migration.add_uniqueness_check :users, :login

    user = User.create(:login => 'fesplugas')

    begin
      User.create(:login => 'fesplugas')
    rescue Exception => error
      assert_match /PGError/, error.message
      assert_match /duplicate key value violates unique constraint "unique_login"/, error.message
    end

  end

  def test_should_add_length_check

    ActiveRecord::Migration.add_length_check :users, :login, :is => 8

    user = User.create(:login => 'esplugas')
    assert_equal 1, User.count

    %w( fesplugas f ).each do |login|

      begin
        User.create :login => login
      rescue Exception => error
        assert_match /PGError/, error.message
        assert_match /violates check constraint "valid_login"/, error.message
      end

    end

  end

  def test_should_add_positive_check

    ActiveRecord::Migration.add_positive_check :products, :price

    Product.create(:price => 1)
    assert_equal 1, Product.count

    [ 0, -1 ].each do |value|

      begin
        Product.create :price => value
      rescue Exception => error
        assert_match /PGError/, error.message
        assert_match /violates check constraint "valid_price"/, error.message
      end

    end

  end

end