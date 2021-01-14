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

          # 山札を準備する
          match(/-init[ 　]([a-zA-Z0-9_]+)/, method: :init_deck)
          match(/-init-channel[ 　]([a-zA-Z0-9_]+)/, method: :init_deck)
          match(/-init-server[ 　]([a-zA-Z0-9_]+)/, method: :init_deck_server)

          # 山札からカードを引く
          match(/[ 　]+([a-zA-Z0-9_]+)(?:[ 　]+(\d+))?/, method: :drow)

          # 山札を片付ける
          match(/-clean[ 　]([a-zA-Z0-9_]+)/, method: :clean_deck)
          match(/-clean-channel[ 　]([a-zA-Z0-9_]+)/, method: :clean_deck)
          match(/-clean-server[ 　]([a-zA-Z0-9_]+)/, method: :clean_deck_server)

          def initialize(*)
            super

            prepare_generator
          end

          # 山札を準備する
          # @param [Event] m
          # @param [String] table_name 山札を準備するオリジナル表
          # @param [Boolean] server_wide サーバ共通の山札にする
          # @return [void]
          def init_deck(m, table_name, server_wide = false)
            log_incoming(m)

            result =
              @generator.init_deck(
                table_name,
                m.server.id,
                server_wide ? 0 : m.channel.id
              )

            send_channel(m.channel, result.messages, "deck-init[#{m.user.mention}]<#{table_name}>(#{result.header}): ")
          end

          # サーバ共通の山札を準備する
          # @param [Event] m
          # @param [String] table_name 山札を準備するオリジナル表
          # @return [void]
          def init_deck_server(m, table_name)
            init_deck(m, table_name, true)
          end

          # カードを引くコマンドに反応する
          # @param [Event] m
          # @param [String] table_name カードを引く山札
          # @param [Integer, String] count カードを引く枚数
          # @return [void]
          def drow(m, table_name, count)
            log_incoming(m)

            header = "deck[#{m.user.mention}]<#{table_name}>"
            count = count.nil? ? 1 : count.to_i

            return if count < 1

            result = @generator.drow(table_name, m.server.id, m.channel.id, count)

            send_channel(
              m.channel,
              result.messages,
              header +
                (result.header ? "(#{result.header}): " : ": ")
            )
          end

          # 山札を片付ける
          # @param [Event] m
          # @param [String] table_name 山札の元になったオリジナル表の名前
          # @param [Boolean] server_wide サーバ共通の山札を対象にする
          # @return [void]
          def clean_deck(m, table_name, server_wide = false)
            log_incoming(m)

            result =
              @generator.clean_deck(
                table_name,
                m.server.id,
                server_wide ? 0 : m.channel.id
              )

            send_channel(m.channel, result.messages, "deck-clean[#{m.user.mention}]<#{table_name}>(#{result.header}): ")
          end

          # サーバ共通の山札を片付ける
          # @param [Event] m
          # @param [String] table_name 山札の元になったオリジナル表の名前
          # @return [void]
          def clean_deck_server(m, table_name)
            clean_deck(m, table_name, true)
          end
        end
      end
    end
  end
end
