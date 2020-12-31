class MypageController < ApplicationController
  before_action :require_sign_in
  before_action :authenticate_user!

  def index
    @user = User.find(current_user.id)
  end
end
