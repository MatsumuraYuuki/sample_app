require "test_helper"

class MicropostsInterface < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    log_in_as(@user)
  end
end

class MicropostsInterfaceTest < MicropostsInterface

  test "should paginate microposts" do
    get root_path
    assert_select 'div.pagination'
  end

  #何も書かれていない投稿がなされないことを確認
  test "should show errors but not create micropost on invalid submission" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'  # 正しいページネーションリンク
  end

  test "should create a micropost on valid submission" do
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  # ぺージ内のすべての<a>タグを対象に、そのリンクのテキストが「delete」であるものが存在するかどうかを確認
  test "should have micropost delete links on own profile page" do
    get user_path(@user)
    assert_select 'a', text: 'delete'
  end

  test "should be able to delete own micropost" do
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  test "should not have delete links on other user's profile page" do
    get user_path(users(:archer))
    assert_select 'a', { text: 'delete', count: 0 }
  end
end


# サイドバーの設定は_user_info.html.erbに記述
class MicropostSidebarTest < MicropostsInterface

  test "should display the right micropost count" do
    get root_path
    #<body>に#{@user.microposts.count} micropostsが表示されているか
    assert_match "#{@user.microposts.count} microposts", response.body
  end

  test "should user proper pluralization for zero microposts" do
    log_in_as(users(:malory))
    get root_path
    assert_match "0 microposts", response.body
  end

  test "should user proper pluralization for one micropost" do
    log_in_as(users(:lana))
    get root_path
    assert_match "1 micropost", response.body
  end
end

class ImageUploadTest < MicropostsInterface

  # 画像アップロード用のファイル入力フィールドをテストする
  test "should have a file input field for images" do
    get root_path
    assert_select 'input[type=file]'
  end

  test "should be able to attach an image" do
    cont = "This micropost really ties the room together."
    # fixture_file_uploadというメソッドは、fixtureで定義されたファイルをアップロードする特別なメソッド
    img  = fixture_file_upload('kitten.jpg', 'image/jpeg')
    post microposts_path, params: { micropost: { content: cont, image: img } }
    # コントローラのインスタンス変数@micropostに画像が正常に添付されたかを確認
    assert assigns(:micropost).image.attached?
  end
end