# vim: fileencoding=utf-8

require 'chat_bots/plugin_base/discord_adapter'

module Cd2c
  module ChatBots
    module Plugin
      # アカウント連携確認を行なう
      # @ToDo: 現在はチャットから来た情報を鵜呑みにする
      #   しかし、総当たりでトークンを入力されたときのために、
      #   該当するトークンの持ち主にメールで確認をした方が良いはず
      module AccountConfirmation
        class DiscordAdapter
          include PluginBase::DiscordAdapter

          set(plugin_name: 'AccountConfirmation')
          self.prefix = '.'

          match(/confirm[ 　]([a-zA-Z0-9]{32})/, method: :confirm)

          # アカウント連携確認コマンドに反応する
          # @param [Event] m
          # @return [void]
          def confirm(m, token)
            log_incoming(m)
            message = "#{m.user.mention} "

            begin
              matched_token = check_token(token)
              if matched_token.nil?
                message = "#{message}指定されたトークンが存在しません"
              else
                authentication_account_with_token(m, matched_token)
                message = "#{message}アカウント連携が完了しました"
              end
            rescue ActiveRecord::RecordInvalid => e
              log(e.record.errors.to_s, :warn)
            rescue TooManyMatchedTokensError => e
              log("トークン多重生成エラー", :warn)
              message = "#{message}トークンを再発行してください"
            rescue => e
              log_exception(e)
              message = "#{message}原因不明のエラーが発生しました"
            end

            send_channel(m.channel, message)
          end

          private

          # トークンを検索する
          # @param [String] token
          # @return [ChatSystemAuthenticationToken]
          def check_token(token)
            tokens = []
            synchronize(RECORD_MESSAGE) do
              ApplicationRecord.connection_pool.with_connection do
                tokens = ChatSystemAuthenticationToken.get(token: token)
              end
            end

            if tokens.size < 1
              nil
            elsif tokens.size > 1
              raise TooManyMatchedTokensError
            else
              tokens.first
            end
          end

          # トークンとアカウントを紐付ける
          # @param [Event] m
          # @param [ChatSystemAuthenticationToken] token
          # @return [void]
          def authentication_account_with_token(m, token)
            link = ChatSystemLink.new
            link.user = token.user
            link.server_id = m.server.id
            link.account_id = m.user.id
            link.chat_system = ChatSystem.find_by(name: :discord)

            synchronize(RECORD_MESSAGE) do
              ApplicationRecord.connection_pool.with_connection do
                ApplicationRecord.transaction do
                  link.save!
                  token.destroy!
                end
              end
            end
          end
        end
      end
    end
  end
end
