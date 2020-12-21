class ChatSystemAuthenticationToken < ApplicationRecord
  belongs_to :user

  before_save :generate_token

  private

  # トークンを生成します。
  # @return [self]
  def generate_token
    self.token = SecureRandom.alphanumeric(32)
  end
end
