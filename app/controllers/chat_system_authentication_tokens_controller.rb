class ChatSystemAuthenticationTokensController < ApplicationController
  before_action :require_sign_in
  before_action :authenticate_user!

  def index
    @token_records = ChatSystemAuthenticationToken.find(user: current_user)
  end

  def new
    @token_record = ChatSystemAuthenticationToken.new
  end

  def create
    @token_record = ChatSystemAuthenticationToken.new
    @token_record.user = current_user

    if @token_record.save
      flash[:success] = t('views.flash.added_original_table')
      redirect_to(user_path)
    else
      render(:new)
    end
  end

  def destroy
    @token_record = ChatSystemAuthenticationToken.find(param[:id])

    if @token_record.destroy
      flash[:success] = t('views.flash.deleted_chat_system_authentication_token')
      redirect_to(user_path)
    else
      render(:new)
    end
  end
end
