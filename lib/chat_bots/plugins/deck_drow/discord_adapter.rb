# vim: fileencoding=utf-8

require 'chat_bots/plugin_base/discord_adapter'
require_relative 'generator'
require_relative 'original_table_not_found'
require_relative 'table_deck_not_found'

module Cd2c
  module ChatBots
    module Plugin
      # オリジナル表から山札を構成してカードを引く
      module DeckDrow
        class DiscordAdapter
          include PluginBase::DiscordAdapter

          set(plugin_name: 'DeckDrow')
          self.prefix = '.deck'

          match(/-init[ 　]([a-zA-Z0-9_]+)/, method: :init_deck)
          match(/-init-server[ 　]([a-zA-Z0-9_]+)/, method: :init_deck)
          match(/-init-channel[ 　]([a-zA-Z0-9_]+)/, method: :init_deck_channel)
          match(/[ 　]+([a-zA-Z0-9_]+)(?:[ 　]+(\d+))?/, method: :drow)

          def initialize(*)
            super

            prepare_generator
          end

          # 山札を準備する
          # @param [Event] m
          # @param [String] table_name 山札を準備するオリジナル表
          # @param [Boolean] channel_only チャンネル限定の山札にする
          #   デフォルトではサーバ内の全チャンネルで山札は共通になる
          # @return [void]
          def init_deck(m, table_name, channel_only = false)
            log_incoming(m)

            message =
              begin
                @generator.init_deck(
                  table_name,
                  m.server.id,
                  channel_only ? m.channel.id : 0
                )
              rescue OriginalTableNotFound => not_found_error
                ": オリジナル表「#{not_found_error.table}」が見つかりません"
              rescue TableDeckNotFound => not_found_error
                ": 山札「#{not_found_error.table}」が見つかりません"
              rescue => e
                log_exception(e)
                '原因不明のエラーが発生しました'
              end

            send_channel(m.channel, message, "deck-init[#{m.user.mention}]: ")
          end

          # チャンネル限定の山札を準備する
          # @param [Event] m
          # @param [String] table_name 山札を準備するオリジナル表
          # @return [void]
          def init_deck_channel(m, table_name)
            init_deck(m, table_name, true)
          end

          # カードを引くコマンドに反応する
          # @param [Event] m
          # @param [String] table_name カードを引く山札
          # @param [Integer, String] count カードを引く枚数
          # @return [void]
          def drow(m, table_name, count)
            log_incoming(m)

            header = "deck[#{m.user.mention}] "
            count = count.nil? ? 1 : count.to_i

            messages =
              begin
                result = Array.new(count).map do
                  @generator.drow(table_name, m.server.id, m.channel.id)
                end
                if result.include?(nil)
                  result =
                    result.compact << '山札にカードが残っていません'
                end
                header = "#{header}<#{table_name}>: "
                result
            rescue OriginalTableNotFound => not_found_error
              ": オリジナル表「#{not_found_error.table}」が見つかりません"
            rescue TableDeckNotFound => not_found_error
              ": 山札「#{not_found_error.table}」が見つかりません"
            rescue => e
              log_exception(e)
              '原因不明のエラーが発生しました'
            end

            send_channel(m.channel, messages, header)
          end
        end
      end
    end
  end
end
