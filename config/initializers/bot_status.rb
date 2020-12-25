bot_status_config = OpenStruct.new
bot_status_config.socket_path = "#{Rails.root}/tmp/sockets/chat_bots-discord.sock"
Rails.application.config.bot_status = bot_status_config
