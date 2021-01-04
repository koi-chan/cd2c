class CreateTableDecks < ActiveRecord::Migration[6.1]
  def change
    create_table :table_decks do |t|
      t.references :chat_system, null: false, foreign_key: true
      t.bigint :server_id, null: false
      t.bigint :channel_id
      t.references :original_table, null: false, foreign_key: true
      t.text :rest_contents, null: false

      t.timestamps
    end
  end
end
