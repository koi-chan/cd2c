class AddColumnChatSystemIdToChatSystemLinks < ActiveRecord::Migration[6.1]
  def change
    add_reference :chat_system_links, :chat_system, null: false, foreign_key: true
  end
end
