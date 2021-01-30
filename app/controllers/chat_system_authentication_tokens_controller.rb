class ChatSystemAuthenticationTokensController < ApplicationController
  before_action :require_sign_in

  def new
    @token_record = ChatSystemAuthenticationToken.new
    @chat_systems = ChatSystem.all
  end

  def create
    @token_record = ChatSystemAuthenticationToken.new(params_for_create)
    @token_record.user = current_user

    if @token_record.save
      flash[:success] = t('views.flash.added_original_table')
      redirect_to(mypage_index_path)
    else
      render(:new)
    end
  end

  def destroy
    @token_record = ChatSystemAuthenticationToken.find(params[:id])

    if @token_record.destroy
      flash[:success] = t('views.flash.deleted_chat_system_authentication_token')
      redirect_to(mypage_index_path)
    else
      render(:new)
    end
  end

  private

  def params_for_create
    params.
      require(:chat_system_authentication_token).
      permit(:chat_system_id)
  end
end
