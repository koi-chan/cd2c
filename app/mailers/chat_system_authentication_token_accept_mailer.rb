class ChatSystemAuthenticationTokenAcceptMailer < ApplicationMailer
  # @param [ChatSystemLink] link
  def send_confirm_to_user(link)
    @link = link
    pp @link
    mail(
      subject: 'チャット環境との連携トークンが使用されました',
      to: @link.user.email,
      from: "#{link.chat_system.name}@vm14.kazagakure.net"
    ) do |format|
      format.text
    end
  end
end
