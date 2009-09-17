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

class PaypalOrder < ActiveRecord::Base
  belongs_to :user, :foreign_key => :paypal_id
end
