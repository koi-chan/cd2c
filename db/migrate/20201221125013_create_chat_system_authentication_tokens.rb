class CreateChatSystemAuthenticationTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_system_authentication_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false

      t.timestamps
    end
  end
end
