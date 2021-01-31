class ChatSystemLinksController < ApplicationController
  before_action :require_sign_in

  def create
    token_records = ChatSystemAuthenticationMail.get(
      token: params[:token],
      user_id: current_user.id
    )

    if token_records.nil?
      flash[:error] = t('views.error.no_matched_tokens')
      redirect_to(root_path)
      return
    end

    token_record = token_records.first
    link = ChatSystemLink.new
    link.user_id = token_record.user_id
    link.server_id = token_record.server_id
    link.account_id = token_record.account_id
    link.chat_system = token_record.chat_system

    begin
      ApplicationRecord.transaction do
        link.save!
        token_record.destroy!
      end

      flash[:success] = t('views.flash.added_chat_system_link')
      redirect_to(mypage_index_path)
    rescue
      flash[:error] = t('views.error')
      redirect_to(root_path)
    end
  end
end
