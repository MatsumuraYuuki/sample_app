require "test_helper"

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    remember(@user)
  end

  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
    # このとき、テストをもう1つ追加している点にご注目ください。このテストでは、ユーザーの記憶ダイジェストが記憶トークンと正しく対応していない場合に現在のユーザーがnilになるかどうかをチェックしています。これによって、次のネストしたif文内のauthenticated?の式をテストします。
    # if user && user.authenticated?(cookies[:remember_token])
  end
end
