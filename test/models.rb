class Category < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :category
end

class Product < ActiveRecord::Base
end

class User < ActiveRecord::Base
end