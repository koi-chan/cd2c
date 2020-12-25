# vim: fileencoding=utf-8

require 'chat_bots/plugin_base/discord_adapter'

module Cd2c
  module ChatBots
    module Plugin
      # バージョンを返す
      module Version
        class DiscordAdapter
          include PluginBase::DiscordAdapter

          set(plugin_name: 'Version')
          self.prefix = '.'

          match(/version/, method: :version)

          # バージョンとコミットIDを返す
          # @param [Event] m
          # @return [void]
          def version(m)
            log_incoming(m)
            send_channel(
              m.channel,
              "#{m.user.mention} #{Rails.application.config.app_status.version_and_commit_id}"
            )
          end
        end
      end
    end
  end
end
