class Post < ApplicationRecord
  has_many :comments, denormalize: { fields: %i[topic] }
  validates :body, presence: true
end
