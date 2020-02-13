class Pizza < ApplicationRecord
  belongs_to :programmer, denormalize: { fields: %i[happiness] }
  validates :owner_name, presence: true
end
