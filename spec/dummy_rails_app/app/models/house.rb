class House < ApplicationRecord
  has_many :rental_agreements
  has_many :renters, through: :rental_agreements
end
