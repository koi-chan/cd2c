class CreateOriginalTables < ActiveRecord::Migration[6.1]
  def change
    create_table :original_tables do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      t.string :definition, null: false

      t.timestamps
    end
  end
end
