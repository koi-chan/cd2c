class RenameDiscordLinksToChatSystemLinks < ActiveRecord::Migration[6.1]
  def change
    rename_table :discord_links, :chat_system_links
  end
end
