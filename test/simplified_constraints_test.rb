ENV['RAILS_ENV'] = 'test'

require 'test/unit'
require 'rubygems'
require 'active_record'
require 'simplified_constraints'

##
# Stablish connection to PostgreSQL +simplified_constraints+
#
ActiveRecord::Base.establish_connection(:adapter => "postgresql", :database => "simplified_constraints")

##
# Create +users+ table
#
class CreateUsers < ActiveRecord::Migration

  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :login
    end
  end

  def self.down
    drop_table :users
  end

end

##
# Create +posts+ table
#
class CreatePosts < ActiveRecord::Migration

  def self.up
    create_table :posts do |t|
      t.string :title
      t.text :body
    end
  end

  def self.down
    drop_table :posts
  end

end

##
# Create +products+ table
#
class CreateProducts < ActiveRecord::Migration

  def self.up
    create_table :products do |t|
      t.string :name
      t.integer :price
    end
  end

  def self.down
    drop_table :products
  end

end

##
# Define User model
#
class User < ActiveRecord::Base; end

##
# Define Post model
#
class Post < ActiveRecord::Base; end

##
# Define Product model
#
class Product < ActiveRecord::Base; end

##
# Here we go with the tests ...
#
class SimplifiedConstraintsTest < Test::Unit::TestCase

  def setup
    CreateUsers.up
    CreatePosts.up
    CreateProducts.up
  end

  def teardown
    CreateProducts.down
    CreatePosts.down
    CreateUsers.down
  end

  def test_should_create_a_user_and_a_post
    user = User.create
    assert User.count, 1
    post = Post.create
    assert Post.count, 1
  end

  def test_should_add_email_check_to_users
    ActiveRecord::Migration.add_email_check :users, :email
    user = User.new
    user.email = "invalid@email"
    assert user.valid?
    begin
      user.save
    rescue Exception => error
      assert_match /PGError/, error.message
      assert_match /violates check constraint "valid_email"/, error.message
    end
    user.email = "valid@email.com"
    assert user.valid?
    user.save
    assert User.count, 1
  end

  def test_should_add_login_check_to_users
    ActiveRecord::Migration.add_login_check :users, :login
    user = User.new
    user.login = "my-login"
    assert user.valid?
    begin
      user.save
    rescue Exception => error
      assert_match /PGError/, error.message
      assert_match /violates check constraint "valid_login"/, error.message
    end
    user.login = "mylogin"
    assert user.valid?
    user.save
    assert User.count, 1
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
    begin
      User.create(:login => 'fesplugas')
    rescue Exception => error
      assert_match /PGError/, error.message
      assert_match /violates check constraint "valid_login"/, error.message
    end
  end

  def test_should_add_positive_check
    ActiveRecord::Migration.add_positive_check :products, :price
    begin
      Product.create(:price => -1)
    rescue Exception => error
      assert_match /PGError/, error.message
      assert_match /violates check constraint "valid_price"/, error.message
    end
    Product.create(:price => 1)
    assert Product.count, 1
  end

end