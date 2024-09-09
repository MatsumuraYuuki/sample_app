require "test_helper"

class UsersLogin < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end
end

class InvalidPasswordTest < UsersLogin

  test "login path" do
    get login_path
    assert_template 'sessions/new'
  end

  test "login with valid email/invalid password" do
    post login_path, params: { session: { email:    @user.email,
                                          password: "invalid" } }
    assert_not is_logged_in?
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end

class ValidLogin < UsersLogin

  def setup
    super
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
  end
end

class ValidLoginTest < ValidLogin

  test "valid login" do
    assert is_logged_in?
    assert_redirected_to @user
  end

  test "redirect after login" do
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end

class Logout < ValidLogin

  def setup
    super
    delete logout_path
  end
end

class LogoutTest < Logout

  test "successful logout" do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "redirect after logout" do
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
  test "should still work after logout in second window" do
    delete logout_path
    assert_redirected_to root_url
  end
end

class RememberingTest < UsersLogin

  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not cookies[:remember_token].blank?
  end

  test "login without remembering" do
    #Cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    #Cookieが削除されていることを検証してからログイン
    log_in_as(@user, remember_me: '0')
    assert cookies[:remember_token].blank?
  end
end



#   test "login with valid email/invalid password" do
#     get login_path
#     assert_template 'sessions/new'
#     post login_path, params: { session: { email:    @user.email,
#                                           password: "invalid" } }
#     assert_not is_logged_in?                                 
#     assert_response :unprocessable_entity
#     assert_template 'sessions/new'
#     assert_not flash.empty?
#     get root_path
#     assert flash.empty?

#     #1ログイン用のパスを開く
#     #2新しいセッションのフォームが正しく表示されたことを確認する
#     #3わざと無効なparamsハッシュを使ってセッション用パスにPOSTする(valid email/invalid password)
#     #4,5新しいセッションのフォームが正しいステータスを返し、再度表示されることを確認する
#     #6フラッシュメッセージが表示されることを確認する
#     #7別のページ（Homeページなど） にいったん移動する
#     #8移動先のページでフラッシュメッセージが表示されていないことを確認する
#   end

#   test "login with valid information followed by logout" do
#     post login_path, params: { session: { email:    @user.email,
#                                           password: 'password' } }
#     assert is_logged_in?   #is_logged_in?を利用できるようにしてあったおかげで簡単にテストできる
#     assert_redirected_to @user
#     follow_redirect!
#     assert_template 'users/show'
#     assert_select "a[href=?]", login_path, count: 0
#     assert_select "a[href=?]", logout_path
#     assert_select "a[href=?]", user_path(@user)
#     #1ログイン用のパスを開く
#     #2セッション用パスに有効な情報をPOSTする
#     #3ログイン用リンクが表示されなくなったことを確認する
#     #4ログアウト用リンクが表示されていることを確認する
#     #5プロフィール用リンクが表示されていることを確認する

#     #8.3で追加　何これ？
#     delete logout_path
#     assert_not is_logged_in?
#     assert_response :see_other
#     assert_redirected_to root_url
#     follow_redirect!
#     assert_select "a[href=?]", login_path
#     assert_select "a[href=?]", logout_path,      count: 0
#     assert_select "a[href=?]", user_path(@user), count: 0
#   end
