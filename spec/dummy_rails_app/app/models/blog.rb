class Blog < ApplicationRecord
  has_many :posts, denormalize: { fields: %i[topic], unless: ->{ topic == 'XXX' } }
end
