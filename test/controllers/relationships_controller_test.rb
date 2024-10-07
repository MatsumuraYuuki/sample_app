require "test_helper"

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  # post relationships_path で新しいリレーションシップが作成されないことを期待
  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      #RelationshipsControllerのcreateアクションが呼び出されるリクエスト
      post relationships_path
    end
    assert_redirected_to login_url
  end

  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end
end
