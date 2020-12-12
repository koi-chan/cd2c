class ApplicationController < ActionController::Base
  private

  def require_sign_in
    redirect_to(new_user_session_url) unless user_signed_in?
  end
end
