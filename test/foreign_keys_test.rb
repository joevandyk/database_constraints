require 'test/helper'

class ForeignKeysTest < Test::Unit::TestCase

  def setup
    Category.destroy_all
    Post.destroy_all
    Product.destroy_all
    User.destroy_all
  end

  def test_should_add_foreign_key_create_items_and_check_fk_constraints

    ActiveRecord::Migration.add_foreign_key :posts, :category_id, :categories

    category = Category.create(:name => 'Code')
    post = category.posts.create(:title => 'Add Foreign Keys')
    begin
      category.destroy
    rescue Exception => error
      assert_match /violates foreign key constraint/, error.message
    end
    assert_equal 1, Category.count
    assert_equal 1, Post.count

    post.destroy
    category.destroy

    ActiveRecord::Migration.remove_foreign_key :posts, :category_id

  end

end