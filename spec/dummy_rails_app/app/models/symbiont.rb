class Symbiont < ApplicationRecord
  belongs_to :symbiont, denormalize: { fields: :happiness, if: :normal? }, optional: true

  def normal?
    happiness.to_i < 1000
  end
end
