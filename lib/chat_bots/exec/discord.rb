# vim: fileencoding=utf-8

require_relative './base'

module Cd2c
  module ChatBots
    module Exec
      # Discord ボットの実行ファイルの処理を担うクラス
      module Discord
        include BaseBot
        extend self

        # プログラムを実行する
        # @param [String] root_path RGRB のルートディレクトリの絶対パス
        # @param [Array<String>] argv コマンドライン引数の配列
        # @return [void]
        def run(root_path, argv)
          @root_path = root_path

          options = parse_options(argv)
          config_id = options[:config_id]
          log_level = options[:log_level]

          @logger = new_logger(log_level[:plugin])
          config = load_config(config_id, options[:mode])
          discord_adapters = load_adapters('discord', config)
          plugin_options = extract_plugin_options(
            config, discord_adapters
          )

          status_server = StatusServer.new(
            Rails.application.config.bot_status.socket_path,
            @logger
          )
          status_server_signal_io_r, status_server_signal_io_w = IO.pipe
          status_server_thread =
            status_server.start_thread(status_server_signal_io_r)

          bot = new_bot(
            config, discord_adapters, plugin_options, log_level
          )

          set_signal_handler(bot, status_server_signal_io_w)

          bot.run

          status_server_thread.join

          @logger.warn('ボットは終了しました')
        end
        module_function :run

        private

        # Discord ボットを作り、設定して返す
        # @param [Config] config RGRB の設定
        # @param [Array<RGRB::DiscordPlugin>] discord_adapters Discord アダプタの配列
        # @param [Hash] plugin_options プラグイン設定
        # @param [Symbol] log_level ログレベル
        # @return [Discordrb::Commands::CommandBot]
        def new_bot(config, discord_adapters, plugin_options, log_level)
          bot_config = config.discord_bot

          bot = Discordrb::Commands::CommandBot.new(
            token: bot_config['Token'],
            client_id: bot_config['ClientID'],
            prefix: ''
          )

          # Lumberjack 用のログモードから、
          # Discordrb 内部処理用のログモードを選択・設定
          bot.mode = log_level[:base]

          # バージョン情報を返すコマンド
          bot.message(contains: /^\.version/) do |event|
            unless event.user.current_bot?
              event << "#{event.user.mention} RGRB #{RGRB::VERSION_WITH_COMMIT_ID}"
            end
          end

          bot.server_create do |event|
            event.server.default_channel.send_message('招待されました')
            u = event.server.members.select do |member|
              member.username == 'koi-chan'
              member.username == 'koi-chan#5021'
            end
            u.first.pm("招待した？ #{u.first.name}")
          end

          # 独自実装のプラグイン機能を読み込む
          discord_adapters.each do |adapter|
            adapter.new(bot, (plugin_options[adapter] || {}), logger)
          end

          @logger.warn('ボットが生成されました')

          bot
        rescue => e
          @logger.fatal('Discord ボットの生成に失敗しました')
          @logger.fatal(e)

          Sysexits.exit(:config_error)
        end

        # オプションを解析する
        # @return [Hash]
        def parse_options(argv)
          default_options = {
            config_id: 'discord',
            mode: 'development'
          }
          default_log_level = {
              plugin: :warn,
              base: :normal
          }
          options = {}
          log_level = {}

          OptionParser.new do |opt|
            opt.banner = "使用法: #{opt.program_name} [オプション]"
            opt.version = Rails.application.config.app_status.version_and_commit_id

            opt.summary_indent = ' ' * 2
            opt.summary_width = 24

            opt.separator('')
            opt.separator('Card Deck Create and Drop for Chat - Discord ボット')

            opt.separator('')
            opt.separator('オプション:')

            opt.on(
              '-c', '--config=CONFIG_ID',
              '設定 CONFIG_ID を読み込みます'
            ) do |config_id|
              options[:config_id] = config_id
            end

            opt.on(
              'm', '--mode=RAILS_ENV',
              '環境を設定します'
            ) do |mode|
              options[:mode] = mode
            end

            opt.on(
              '-v', '--verbose',
              '全てのログを冗長にします'
            ) do
              log_level = {plugin: :info, base: :verbose}
            end

            opt.on(
              '--debug',
              'デバッグモード。全てのログを最も冗長にします。'
            ) do
              log_level = {plugin: :debug, base: :debug}
            end

            opt.on(
              '-p', '--plugin-verbose',
              'プラグインのみログを冗長にします'
            ) do
              log_level[:plugin] = :info
            end

            opt.on(
              '-P', '--plugin-debug',
              'プラグインのログのみデバッグモードにします'
            ) do
              log_level[:plugin] = :debug
            end

            opt.on(
              '-b', '--base-verbose',
              '本体のログのみ冗長にします'
            ) do
              log_level[:base] = :verbose
            end

            opt.on(
              '-B', '--base-debug',
              '本体のログのみデバッグモードにします'
            ) do
              log_level[:base] = :debug
            end

            opt.parse(argv)
          end

          options[:log_level] = default_log_level.merge(log_level)
          default_options.merge(options)
        end

        # シグナルハンドラを設定する
        # @param [Discordrb::Commands::CommandBot] bot Discord ボット
        # @param [IO] status_server_signal_io_w ボットの状態送信用サーバの
        #   シグナル関連コマンド書き込み用IO
        # @return [void]
        def set_signal_handler(bot, status_server_signal_io_w)
          # シグナルを捕捉し、ボットを終了させる処理
          # trap 内で普通に bot.quit すると ThreadError が出るので
          # 新しい Thread で包む
          %i(SIGINT SIGTERM).each do |signal|
            Signal.trap(signal) do
              Thread.new(signal) do |sig|
                bot.stop(true)
                status_server_signal_io_w.write('q')
              end
            end
          end
        end
      end
    end
  end
end
