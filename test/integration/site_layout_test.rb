require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup #10.3.1ユーザーの一覧ページ 演習でエラー解決するために追加
    @user = users(:michael)  # users(:michael) で適切なテストユーザーを取得
  end

  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    get contact_path
    assert_select "title", full_title("Contact")
    get signup_path
    assert_select "title", full_title("Sign up")
  end

  # ログイン済みユーザーのリンク
  test "login links" do
    log_in_as(@user)
    get users_path
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
  end

  #ログアウト状態のユーザーのリンク
  test "logout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", login_path
  end
end
