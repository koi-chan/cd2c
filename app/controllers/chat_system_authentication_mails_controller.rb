class ChatSystemAuthenticationMailsController < ApplicationController
  before_action :require_sign_in

  def destroy
    @token_record = ChatSystemAuthenticationMail.find(params[:id])

    if @token_record.destroy
      flash[:success] = t('views.flash.deleted_chat_system_authentication_mail')
      redirect_to(mypage_index_path)
    else
      render(:new)
    end
  end
end
