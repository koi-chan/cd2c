# vim: fileencoding=utf-8

require 'chat_bots/plugin_base/generator'

module Cd2c
  module ChatBots
    module Plugin
      # オリジナル表からカードデッキとして引く
      module DeckDrow
        class Generator
          include PluginBase::Generator

          DeckDrowResult = Struct.new(:header, :messages, keyword_init: true)

          # 山札を準備する
          # @param [String] table_name 山札を準備するオリジナル表
          # @param [Integer] server_id Discord サーバー ID
          # @param [Integer] channel_id Discord チャンネル ID
          #   0 だとサーバ共通山札を作成する
          # @return [Array<String>]
          def init_deck(table_name, server_id, channel_id = 0)
            result = DeckDrowResult.new(
              header: channel_id == 0 ? 'サーバ共通' : 'チャンネル限定',
            )

            result.messages =
              begin
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
              rescue OriginalTableNotFound => not_found_error
                "オリジナル表「#{not_found_error.table}」が見つかりません"
              rescue TableDeckNotFound => not_found_error
                "山札「#{not_found_error.table}」が見つかりません"
              rescue => e
                log_exception(e)
                '原因不明のエラーが発生しました'
              end

            result
          end

          # TableDeck に保存された山札からカードを引き、結果を返す
          # @param [String] table_name 元になったオリジナル表の名前
          # @param [Integer] server_id Discord サーバー ID
          # @param [Integer] channel_id Discord チャンネル ID
          # @param [Integer] count 山札を引く枚数
          # @return [DeckDrowResult]
          #   header 'サーバ共通' もしくは 'チャンネル限定'
          #   messages カードが残っていないときは nil になる
          # @raise [OriginalTableNotFound] オリジナル表が見つからなかった場合
          # @raise [TableDeckNotFound] 山札が見つからなかった場合
          def drow(table_name, server_id, channel_id, count = 1)
            result = DeckDrowResult.new

            result.messages =
              begin
                original_table = check_original_table_existence_of(table_name)
                table_decks = check_table_deck_existence_of(original_table, server_id, channel_id)

                synchronize(RECORD_MESSAGE) do
                  ApplicationRecord.connection_pool.with_connection do
                    if table_decks.empty?
                      raise(TableDeckNotFound, original_table)
                    else
                      table_deck = table_decks.first
                      result.header = table_deck.channel_id == 0 ? 'サーバ共通' : 'チャンネル限定'
                      result.messages = Array.new(count).map do
                        table_deck.drow(true)
                      end
                    end
                  end
                end

                if result.messages.include?(nil)
                  result.messages.compact << '山札にカードが残っていません'
                end
              rescue OriginalTableNotFound => not_found_error
                "オリジナル表「#{not_found_error.table}」が見つかりません"
              rescue TableDeckNotFound => not_found_error
                "山札「#{not_found_error.table}」が見つかりません"
              rescue => e
                log_exception(e)
                '原因不明のエラーが発生しました'
              end

            result
          end

          # 山札を片付ける
          # @param [String] table_name 山札の素になったオリジナル表の名前
          # @param [Integer] server_id Discord サーバー ID
          # @param [Integer] channel_id Discord チャンネル ID
          #   0 にすると、サーバ共通山札を削除対象にする
          # @return [String]
          def clean_deck(table_name, server_id, channel_id = 0)
            result = DeckDrowResult.new(
              header: channel_id == 0 ? 'サーバ共通' : 'チャンネル限定',
            )

            result.messages =
              begin
                original_table = check_original_table_existence_of(table_name)

                synchronize(RECORD_MESSAGE) do
                  ApplicationRecord.connection_pool.with_connection do
                    table_deck =
                      TableDeck.
                        find_by(
                          original_table: original_table,
                          chat_system: ChatSystem.find_by(name: :discord),
                          server_id: server_id,
                          channel_id: channel_id
                        )
                    if table_deck.nil?
                      raise(TableDeckNotFound, original_table)
                    else
                      table_deck.destroy!
                    end
                  end
                end

                "山札「#{table_name}」を片付けました"
              rescue OriginalTableNotFound => not_found_error
                "オリジナル表「#{not_found_error.table}」が見つかりません"
              rescue TableDeckNotFound => not_found_error
                "山札「#{not_found_error.table}」が見つかりません"
              rescue => e
                log_exception(e)
                '原因不明のエラーが発生しました'
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

          # そのチャンネルで使用可能な山札が存在することを確かめる
          # @param [OriginalTable] original_table 元になったオリジナル表
          # @param [Integer] server_id Discord サーバー ID
          # @param [Integer] channel_id Discord チャンネル ID
          # @return [<TableDeck>]
          # @raise [TableDeckNotFound] 山札が存在しない場合
          def check_table_deck_existence_of(original_table, server_id, channel_id = 0)
            tables = nil

            synchronize(RECORD_MESSAGE) do
              ApplicationRecord.connection_pool.with_connection do
                tables =
                  TableDeck.
                    where(
                      original_table: original_table,
                      chat_system: ChatSystem.find_by(name: :discord),
                      server_id: server_id
                    ).
                    merge(
                      TableDeck.
                        where(channel_id: channel_id).
                        or(TableDeck.where(channel_id: 0))
                    ).
                    order(channel_id: :desc)

                raise(TableDeckNotFound, original_table) if tables.empty?
              end
            end

            tables
          end
        end
      end
    end
  end
end
