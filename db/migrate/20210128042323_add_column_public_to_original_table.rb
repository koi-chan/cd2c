class AddColumnPublicToOriginalTable < ActiveRecord::Migration[6.1]
  def change
    add_column(:original_tables, :public, :boolean, null: false, default: false)
  end
end
