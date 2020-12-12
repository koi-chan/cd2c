class OriginalTable < ApplicationRecord
  belongs_to :user

  def elements
    self.definition.split
  end
end
