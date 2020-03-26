class Pizza < ApplicationRecord
  belongs_to :programmer, denormalize: { fields: %i[happiness] }, optional: true
  validates :owner_name, presence: true
end
