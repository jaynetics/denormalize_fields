class Programmer < ApplicationRecord
  has_one :pizza, denormalize: { fields: %i[name], prefix: :owner_ }
end
