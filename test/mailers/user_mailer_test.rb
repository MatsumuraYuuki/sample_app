require "test_helper"

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    user = users(:michael)  
   #fixtureユーザーに有効化トークンを追加,追加しない場合は有効化トークンが空白になる
    user.activation_token = User.new_token 
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["absol57434@gmail.com"], mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    #URL内の特殊文字（@ や . など）はエンコード（別の形式に変換）されるため、CGI.escape(user.email) を使って、URLでメールアドレスが正しくエンコードされているかどうかを確認しています。
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

end
