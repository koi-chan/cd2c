require "test_helper"

class OriginalTablesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get original_tables_index_url
    assert_response :success
  end

  test "should get new" do
    get original_tables_new_url
    assert_response :success
  end

  test "should get create" do
    get original_tables_create_url
    assert_response :success
  end

  test "should get edit" do
    get original_tables_edit_url
    assert_response :success
  end

  test "should get show" do
    get original_tables_show_url
    assert_response :success
  end

  test "should get update" do
    get original_tables_update_url
    assert_response :success
  end

  test "should get destroy" do
    get original_tables_destroy_url
    assert_response :success
  end
end
