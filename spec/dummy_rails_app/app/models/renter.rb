class Renter < ApplicationRecord
  has_many :rental_agreements
  has_many :houses, through: :rental_agreements,
                    denormalize: { fields: { updated_at: :renter_changed_at } }
end
