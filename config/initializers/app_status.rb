# アプリケーションの状態を取得できるようにする
Rails.application.config.app_status = Cd2c::AppStatus.new(
  Cd2c::Version,
  Time.now,
  Cd2c::AppStatus.get_commit_id
)
