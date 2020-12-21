class CreateDiscordLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :discord_links do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :server_id, null: false
      t.bigint :account_id, null: false

      t.timestamps
    end
  end
end
