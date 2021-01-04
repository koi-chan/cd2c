# vim: fileencoding=utf-8

module Cd2c
  module ChatBots
    module PluginBase
      # プラグインの共通モジュール
      module Common
        # データベース接続制御
        # マルチスレッド同期実行(#synchronize)の分類に使用する
        RECORD_MESSAGE = :record_message

        def initialize(*)
          @semaphores_mutex = Mutex.new
          @semaphores = Hash.new { |h, k| h[k] = Mutex.new }
        end

        # スレッドを同期実行する
        # @see: https://github.com/cinchrb/cinch/blob/master/lib/cinch/bot.rb#L159
        # @param [String, Symbol] name 同時実行するブロックの名前
        # @return [void]
        # @yield 同期実行する処理
        def synchronize(name, &block)
          semaphore = @semaphores_mutex.synchronize { @semaphores[name] }
          semaphore.synchronize(&block)
        end
      end
    end
  end
end
