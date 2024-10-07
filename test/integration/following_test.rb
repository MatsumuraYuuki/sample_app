require "test_helper"

class Following < ActionDispatch::IntegrationTest

  def setup
    @user  = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end
end

class FollowPagesTest < Following

  test "following page" do
    get following_user_path(@user)
    assert_response :success
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      #@userがフォローしている各ユーザーに対して、プロフィールページへのリンクが存在するかを確認
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_response :success
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end
end

class FollowTest < Following
  # ユーザーが他のユーザーを標準の方法(通常のHTTPリクエストを使う方法)でフォローできることを確認する
  test "should follow a user the standard way" do
    assert_difference "@user.following.count", 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
    assert_redirected_to @other
  end
  
  # Hotwireを使う方法（Turbo Streamリクエストを使う方法）の両方でフォローできることを確認
  test "should follow a user with Hotwire" do
    assert_difference "@user.following.count", 1 do
      # Hotwireを使う場合のテストは、format: :turbo_streamオプションを指定する
      post relationships_path(format: :turbo_stream),
           params: { followed_id: @other.id }
    end
  end
end

class Unfollow < Following

  def setup
    super
    @user.follow(@other)
    @relationship = @user.active_relationships.find_by(followed_id: @other.id)
  end
end

class UnfollowTest < Unfollow

  test "should unfollow a user the standard way" do
    assert_difference "@user.following.count", -1 do
      delete relationship_path(@relationship)
    end
    assert_response :see_other
    assert_redirected_to @other
  end

  test "should unfollow a user with Hotwire" do
    assert_difference "@user.following.count", -1 do
      #Hotwireを使う場合のテストは、format: :turbo_streamオプションを指定する
      delete relationship_path(@relationship, format: :turbo_stream)
    end
  end
end