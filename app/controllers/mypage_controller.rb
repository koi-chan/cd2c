class MypageController < ApplicationController
  before_action :require_sign_in

  def index
    @user = User.find(current_user.id)
  end
end
