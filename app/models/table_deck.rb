class TableDeck < ApplicationRecord
  belongs_to :chat_system
  belongs_to :original_table
end
