ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do

  create_table :categories, :force => true do |t|
    t.string :name
  end

  create_table :posts, :force => true do |t|
    t.string :title
    t.text :body
    t.integer :category_id
    t.timestamps
  end

  create_table :products, :force => true do |t|
    t.string :name
    t.integer :price
  end

  create_table :users, :force => true do |t|
    t.string :name
    t.string :email
    t.string :login
  end

end