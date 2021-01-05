# vim: fileencoding=utf-8

require 'chat_bots/plugin_base/discord_adapter'
require_relative 'generator'
require_relative 'table_not_found'

module Cd2c
  module ChatBots
    module Plugin
      # オリジナル表から山札を構成してカードを引く
      module DeckDrow
        class DiscordAdapter
          include PluginBase::DiscordAdapter

          set(plugin_name: 'DeckDrow')
          self.prefix = '.deck'

          match(/[ 　]([a-zA-Z0-9_]+)/, method: :drow)

          def initialize(*)
            super

            prepare_generator
          end

          # カードを引くコマンドに反応する
          # @param [Event] m
          # @return [void]
          def drow(m, table_names)
            log_incoming(m)

            messages = table_names.split(' ').map do |table|
              begin
                @generator.random_drow(table).
                  split($/).
                  map { |line| "<#{table}>: #{line}" }
              rescue TableNotFound => not_found_error
                ":「#{not_found_error.table}」という表は見つかりませんでした"
              rescue => e
                log_exception(e)
                '原因不明のエラーが発生しました'
              end
            end

            send_channel(m.channel, messages.flatten, "deck[#{m.user.mention}] ")
          end
        end
      end
    end
  end
end
