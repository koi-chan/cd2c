# vim: fileencoding=utf-8

require 'chat_bots/plugin_base/generator'

module Cd2c
  module ChatBots
    module Plugin
      # オリジナル表からカードデッキとして引く
      module DeckDrow
        class Generator
          include PluginBase::Generator

          # ランダムに1項目をオリジナル表から引き、結果を返す
          # @param [String] table_name 表名
          # @return [String]
          # @raise [TableNotFound] 表が見つからなかった場合
          def random_drow(table_name)
            table = check_existence_of(table_name)

            table.drow
          end

          private

          # 表が存在することを確かめる
          # @param [String] table_name 表名
          # @return [OriginalTable] 表が存在する場合
          # @raise [TableNotFound] 表が存在しない場合
          def check_existence_of(table_name)
            tables = []
            synchronize(RECORD_MESSAGE) do
              ApplicationRecord.connection_pool.with_connection do
                tables = OriginalTable.where(name: table_name)
              end
            end

            fail(TableNotFound, table_name) if tables.size < 1

            tables.first
          end
        end
      end
    end
  end
end
