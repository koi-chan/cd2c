class AddColumnChatSystemToChatSystemAuthenticationTokens < ActiveRecord::Migration[6.1]
  def change
    add_column(:chat_system_authentication_tokens, :chat_system_id, :bigint, null: false)
    add_index(:chat_system_authentication_tokens, :chat_system_id)
  end
end
