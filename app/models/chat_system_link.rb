class ChatSystemLink < ApplicationRecord
  belongs_to :user
  belongs_to :chat_system
end
