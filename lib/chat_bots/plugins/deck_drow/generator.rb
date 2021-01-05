# vim: fileencoding=utf-8

require 'chat_bots/plugin_base/generator'

module Cd2c
  module ChatBots
    module Plugin
      # オリジナル表からカードデッキとして引く
      module DeckDrow
        class Generator
          include PluginBase::Generator

          # 山札を準備する
          # @param [String] table_name 山札を準備するオリジナル表
          # @param [Integer] server_id Discord サーバー ID
          # @param [Integer] channel_id Discord チャンネル ID
          # @return [String]
          def init_deck(table_name, server_id, channel_id = 0)
            original_table = check_original_table_existence_of(table_name)

            synchronize(RECORD_MESSAGE) do
              ApplicationRecord.connection_pool.with_connection do
                table_deck = TableDeck.find_or_initialize_by(
                  original_table: original_table,
                  chat_system: ChatSystem.find_by(name: :discord),
                  server_id: server_id,
                  channel_id: channel_id
                )
                table_deck.init_deck
                table_deck.save!
              end
            end

            "オリジナル表「#{table_name}」を元に山札を準備しました"
          end

          # TableDeck に保存された山札から1枚のカードを引き、結果を返す
          # @param [String] table_name 元になったオリジナル表の名前
          # @param [Integer] server_id Discord サーバー ID
          # @param [Integer] channel_id Discord チャンネル ID
          # @return [String/nil] カードが残っていないときは nil になる
          # @raise [OriginalTableNotFound] オリジナル表が見つからなかった場合
          # @raise [TableDeckNotFound] 山札が見つからなかった場合
          def drow(table_name, server_id, channel_id)
            original_table = check_original_table_existence_of(table_name)
            table_deck = check_table_deck_existence_of(original_table, server_id, channel_id)
            result = nil

            synchronize(RECORD_MESSAGE) do
              ApplicationRecord.connection_pool.with_connection do
                result = table_deck.drow(true)
              end
            end

            result
          end

          private

          # オリジナル表が存在することを確かめる
          # @param [String] table_name 表名
          # @return [OriginalTable] 表が存在する場合
          # @raise [OriginalTableNotFound] 表が存在しない場合
          def check_original_table_existence_of(table_name)
            table = nil

            synchronize(RECORD_MESSAGE) do
              ApplicationRecord.connection_pool.with_connection do
                table = OriginalTable.find_by(name: table_name)
              end
            end

            raise(OriginalTableNotFound, table_name) unless table

            table
          end

          # 山札が存在することを確かめる
          # @param [OriginalTable] original_table 元になったオリジナル表
          # @param [Integer] server_id Discord サーバー ID
          # @param [Integer] channel_id Discord チャンネル ID
          # @return [TableDeck]
          # @raise [TableDeckNotFound] 山札が存在しない場合
          def check_table_deck_existence_of(original_table, server_id, channel_id)
            tables = nil

            synchronize(RECORD_MESSAGE) do
              ApplicationRecord.connection_pool.with_connection do
                tables = TableDeck.where(
                  original_table: original_table,
                  chat_system: ChatSystem.find_by(name: :discord),
                  server_id: server_id
                ).merge(
                  TableDeck.where(channel_id: channel_id)
                    .or(TableDeck.where(channel_id: 0))
                ).order(channel_id: :desc).limit(1)

                raise(TableDeckNotFound, original_table) if tables.empty?
              end
            end

            tables.first
          end
        end
      end
    end
  end
end
