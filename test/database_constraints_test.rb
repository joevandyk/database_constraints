require 'test/helper'

class DatabaseConstraintsTest < Test::Unit::TestCase

  def setup
    Category.destroy_all
    Post.destroy_all
    Product.destroy_all
    PaypalOrder.destroy_all
    User.destroy_all
  end

  def test_should_add_email_check

    ActiveRecord::Migration.add_email_check :users, :email

    valid_emails = %w( john@example.com john@example.co.uk john@example.es )
    valid_emails.each do |email|
      User.create :email => email
    end
    assert_equal valid_emails.size, User.count

    count = 0

    invalid_emails = %w( invalid invalid.com invalid@DEMO.COM invalid@DEMO.com INVALID@example.com )
    invalid_emails.each do |email|

      begin
        User.create :email => email
      rescue Exception => error
        assert_match /PGError/, error.message
        assert_match /violates check constraint "valid_email"/, error.message
        count += 1
      end

    end

    assert_equal invalid_emails.size, count

    ActiveRecord::Migration.remove_email_check :users, :email

  end

  def test_should_add_login_check

    ActiveRecord::Migration.add_login_check :users, :login

    valid_logins = [ 'abcd', '1234567890', 'ABCD' ]
    valid_logins.each do |login|
      User.create :login => login
    end
    assert_equal valid_logins.size, User.count

    invalid_logins = [ '?', '+' ]
    count = 0

    invalid_logins.each do |login|

      begin
        User.create :login => login
      rescue Exception => error
        assert_match /PGError/, error.message
        assert_match /violates check constraint "valid_login"/, error.message
        count += 1
      end

    end

    assert_equal invalid_logins.size, count

    ActiveRecord::Migration.remove_login_check :users, :login

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

    ActiveRecord::Migration.remove_uniqueness_check :users, :login

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

    ActiveRecord::Migration.remove_length_check :users, :login

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

    ActiveRecord::Migration.remove_positive_check :products, :price

  end

end
