class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable

  has_many :chat_system_authentication_tokens
  has_many :chat_system_authentication_mails
  has_many :chat_system_links
  has_many :original_tables
end
