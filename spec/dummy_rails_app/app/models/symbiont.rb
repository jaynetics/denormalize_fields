class Symbiont < ApplicationRecord
  belongs_to :symbiont, denormalize: { fields: :happiness }, optional: true
end
