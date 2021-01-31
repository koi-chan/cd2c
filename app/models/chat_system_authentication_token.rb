class ChatSystemAuthenticationToken < ApplicationRecord
  belongs_to :user
  belongs_to :chat_system

  before_save :generate_token

  # トークンの有効期限(時間)
  TOKEN_EXPIRE_HOURS = 24

  # トークンが存在し、有効期限内であれば結果を返す
  # @param [String] token 検索するトークン
  # @return [self]
  def self.get(token: nil, user_id: nil)
    raise(ArgumentError) if token.nil? && user_id.nil?

    tokens = self.
      where(created_at: Range.new(TOKEN_EXPIRE_HOURS.hours.before, Time.now))

    tokens = tokens.where(token: token) unless token.nil?
    tokens = tokens.where(user_id: user_id) unless user_id.nil?

    tokens
  end

  # トークンの有効期限
  # @return [ActiveSupport::TimeWithZone]
  def expire_at
    self.created_at + TOKEN_EXPIRE_HOURS.hours
  end

  private

  # トークンを生成する
  # @return [self]
  def generate_token
    self.token = SecureRandom.alphanumeric(32)
  end
end
