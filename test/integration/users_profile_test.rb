require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  #Applicationヘルパーを読み込んだことでfull_titleヘルパーが利用できている
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    # 見出しタグh1の内側にある、gravatarクラス付きのimgタグがあるかどうかをチェック
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination',count: 1  #ここを追加
    #micropost.contentの中に１つ１つのマイクロポストの内容が代入され、それが検証される。例えば１つ目のマイクロポストが’hello’だったらそれがあるのかどうか検証されている
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body 
    end
  end
end
