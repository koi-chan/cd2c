require 'chat_bots/status_client'

class ChatSystemLink < ApplicationRecord
  belongs_to :user
  belongs_to :chat_system

  def server
    bot_status_client = Cd2c::ChatBots::StatusClient.new(
      Rails.application.config.bot_status.socket_path,
      Rails.logger
    )
    bot_status = nil
    exception_on_fetching_bot_status = nil

    begin
      bot_status = bot_status_client.fetch("server #{server_id}", 5)
    rescue => e
      exception_on_fetching_bot_status = e
    end

    bot_status || server_id
  end

  def account
    bot_status_client = Cd2c::ChatBots::StatusClient.new(
      Rails.application.config.bot_status.socket_path,
      Rails.logger
    )
    bot_status = nil
    exception_on_fetching_bot_status = nil

    begin
      bot_status = bot_status_client.fetch("user #{server_id} #{account_id}", 5)
    rescue => e
      exception_on_fetching_bot_status = e
    end

    bot_status || account_id
  end

end
