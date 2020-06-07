class King < ApplicationRecord
  has_many :pizzas, denormalize: { fields: { %i[first_name last_name] => :owner_name } }
end
