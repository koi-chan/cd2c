class CreateChatSystemAuthenticationMails < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_system_authentication_mails do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.references :chat_system, null: false, foreign_key: true
      t.bigint :server_id, null: false
      t.bigint :account_id, null: false

      t.timestamps
    end
  end
end
