# vim: fileencoding=utf-8

module Cd2c
  module ChatBots
    module Plugin
      module DeckDrow
        class TableNotFound < StandardError
          # 見つからなかった表名
          # @return [String]
          attr_reader :table

          def initialize(table = nil, error_message = nil)
            if !error_message && table
              error_message = "表 #{table} が見つかりません"
            end

            super(error_message)

            @table = table
          end
        end
      end
    end
  end
end
