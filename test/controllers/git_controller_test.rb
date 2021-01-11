require 'test_helper'

class GitControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get git_login_url
    assert_response :success
  end

end
