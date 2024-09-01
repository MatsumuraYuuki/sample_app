require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      #↓ /usersに対してHTTP POSTリクエストを送り、createアクションを呼ぶことで新しいユーザーを作成します。
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
    assert_select 'div.alert-danger'
  end

  test "valid signup information" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
    # is_logged_in?でユーザー登録の終わったら即座にログイン状態になっているかどうかを確認してる
    # リスト 8.41:ユーザー登録後のログインのテストでassert_not flash.empty?が消えてた何故？
  end
end
