ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do

  create_table :categories, :force => true do |t|
    t.string :name
  end

  create_table :posts, :force => true do |t|
    t.text :body
    t.integer :category_id
    t.string :title
  end

  create_table :products, :force => true do |t|
    t.string :name
    t.integer :price
  end

  create_table :users, :force => true do |t|
    t.string :email
    t.string :login
    t.string :name
  end

end