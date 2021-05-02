require 'chat_bots/status_client'

class ChatSystemLink < ApplicationRecord
  belongs_to :user
  belongs_to :chat_system

  validate :validate_uniqueness

  # サーバの名前を返す
  # チャットボットが起動していたら、チャットシステムから名前を取得する
  # 起動していなければ、データベースに保存されている ID を返す
  # return [Integer/String]
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

  # アカウントの名前を返す
  # チャットボットが起動していたら、チャットシステムから名前を取得する
  # 起動していなければ、データベースに保存されている ID を返す
  # return [Integer/String]
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

  private

  # 既に連携済みのチャットシステムのアカウントを重複して連携登録させない
  # return [Boolean]
  def validate_uniqueness
    case chat_system_id
    when 1
      # discord
      # server_id と account_id が両方とも同一の場合、
      # 同じチャットアカウントと見做す
      if self.where(server_id: server_id, account_id: account_id).count > 0
        errors.add(:account_id, '既にこのアカウントは連携されています')
      end
    end
  end
end
