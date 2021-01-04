class CreateChatSystems < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_systems do |t|
      t.string :name

      t.timestamps
    end
  end
end
