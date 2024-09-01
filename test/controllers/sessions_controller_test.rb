require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get login_path  
    #get '/login',　to: 'sessions#new'　このルートにより、login_pathが/loginのURLにマッピングされます。
    assert_response :success
  end

end
