# vim: fileencoding=utf-8

require 'lumberjack'
require 'discordrb'
require 'optparse'
require 'sysexits'

require_relative './config'
require_relative './plugins_loader'
require_relative '../plugin_base/adapter_options'
require_relative '../status_server'

module Cd2c
  module ChatBots
    module Exec
      # チャット環境ごとに共通なボットの実行処理を担うクラス
      module BaseBot
        private

        # 設定を読み込む
        # @param [String] config_id 設定 ID
        # @param [String] mode 実行モード (RAILS_ENV)
        # @return [Config]
        def load_config(config_id, mode)
          config = Config.load_yaml_file(
            config_id,
            "#{@root_path}/config/chat_bots",
            mode
          )
          @logger.warn("設定 #{config_id} を読み込みました")

          config
        rescue => e
          @logger.fatal('設定ファイルの読み込みに失敗しました')
          @logger.fatal(e)

          Sysexits.exit(:config_error)
        end

        # プラグインのアダプタを読み込む
        # @param [String] chat 接続対象のチャット環境
        # @param [Config] config RGRB の設定
        # @return [Array<Cinch::Plugin>] 読み込まれた IRC アダプタの配列
        def load_adapters(chat, config)
          loader = PluginsLoader.new(config)
          adapters = loader.load_each("#{chat.capitalize}Adapter".to_sym)

          adapters.each do |adapter|
            @logger.warn(
              "プラグイン #{adapter.plugin_name} を読み込みました"
            )
          end

          adapters
        rescue LoadError, StandardError => e
          @logger.fatal('プラグインの読み込みに失敗しました')
          @logger.fatal(e)

          Sysexits.exit(:config_error)
        end

        # 設定から読み込まれたプラグインの設定を抽出する
        # @param [Config] config RGRB の設定
        # @param [Array<xxxPlugin>] loaded_adapters 読み込まれた
        #   アダプタの配列
        # @return [Hash] プラグイン設定
        def extract_plugin_options(
          config, loaded_adapters
        )
          plugin_options = {}

          loaded_adapters.each do |adapter|
            plugin_name = adapter.plugin_name
            plugin_config = config.plugin_config[plugin_name] || {}

            plugin_options[adapter] = PluginBase::AdapterOptions.new(
              config.id,
              @root_path,
              plugin_config,
              @logger
            )

            @logger.warn(
              "プラグイン #{plugin_name} の設定を読み込みました"
            ) if plugin_config
          end

          plugin_options
        rescue => e
          @logger.fatal('プラグイン設定の読み込みに失敗しました')
          @logger.fatal(e)

          Sysexits.exit(:config_error)
        end

        # 新しいロガーを作り、設定して返す
        # @param [Symbol] log_level ログレベル
        # @return [Logger]
        def new_logger(log_level)
          lumberjack_log_level =
            Lumberjack::Severity.const_get(log_level.upcase)

          Lumberjack::Logger.new(
            $stdout,
            progname: self.to_s,
            level: lumberjack_log_level
          )
        end
      end
    end
  end
end
