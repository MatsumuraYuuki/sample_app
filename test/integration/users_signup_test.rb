require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < UsersSignup

  test "invalid signup information" do
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
    assert_select 'div.field_with_errors'
  end

  test "valid signup information with account activation" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    # assert_template 'users/show'
    # assert is_logged_in?
    # is_logged_in?でユーザー登録の終わったら即座にログイン状態になっているかどうかを確認してる
    # リスト 8.41:ユーザー登録後のログインのテストでassert_not flash.empty?が消えてた何故？
  end
end

class AccountActivationTest < UsersSignup

  def setup
    super
    post users_path, params: { user: {  name:  "Example User",
                                        email: "user@example.com",
                                        password:              "password",
                                        password_confirmation: "password" } }
    #post users_pathはcreateアクションを呼ぶのでそこのインスタンス変数にアクセスする
    # テストではコントローラ内で設定されたインスタンス変数に直接アクセスできないがassignsを使うことで、コントローラのインスタンス変数を取得し、それを使ってテスト内で値が正しいかどうか確認したり、他の操作に使える
    @user = assigns(:user)
  end

  #ユーザー登録後のアカウントがすぐに有効化されていないことを確認するテスト
  test "should not be activated" do
    assert_not @user.activated?
  end

#アカウントのアクティベーションが行われていない場合に、ユーザーがログインできないことを確認する
  test "should not be able to log in before account activation" do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  #無効なアクティベーショントークンでのログイン不可
  test "should not be able to log in with invalid activation token" do
    get edit_account_activation_path("invalid token", email: @user.email)
    assert_not is_logged_in?
  end

  #無効なメールでのログイン不可
  test "should not be able to log in with invalid email" do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not is_logged_in?
  end

  #正しいアクティベーショントークンとメールでの成功ログイン
  test "should log in successfully with valid activation token and email" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
