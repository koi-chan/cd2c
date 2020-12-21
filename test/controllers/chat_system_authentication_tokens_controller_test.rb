require "test_helper"

class ChatSystemAuthenticationTokensControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get chat_system_authentication_tokens_index_url
    assert_response :success
  end

  test "should get new" do
    get chat_system_authentication_tokens_new_url
    assert_response :success
  end

  test "should get create" do
    get chat_system_authentication_tokens_create_url
    assert_response :success
  end

  test "should get destroy" do
    get chat_system_authentication_tokens_destroy_url
    assert_response :success
  end
end
