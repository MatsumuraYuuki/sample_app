# user.rbに定義されているものは、モデルがデータに関連するロジックを持つべきものである
#例えば、ユーザーがパスワードリセットの期限を過ぎているかどうかを判断するロジックは、ユーザーというデータに直接関連しています。そのため、このようなメソッドは User モデル内に置かれるべきです。

class User < ApplicationRecord
  # モデルとモデルの間に関連付け(association)を設定. ユーザーが投稿したマイクロポストも一緒に削除される
  has_many :microposts, dependent: :destroy
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A(?!.*\.\.)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/iから修正。9章、セッションのパートでエラーになったので。原因は連続ドット(..)のパターンが含まれていても許可してしまうことがあるため。
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
   # rememberメソッドはremember(user)メソッドから内部で呼び出される。sessions_helper.rbで定義
   # rememberメソッドが呼び出されると、ユーザーオブジェクトに対して新しい remember_token が生成され、そのハッシュ化された値が remember_digest としてdbに保存されます。
   # 次回の訪問時:
   # ユーザーがサイトを再訪問すると、ブラウザに保存されている remember_token がサーバーに送信されます。
   # サーバー側で、送信されたトークンとデータベースに保存されている remember_digest を照合することで、ユーザーが正しく認証されたかどうかを判断します。
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  # この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    # sendメソッドによって、remember_token・activation_token・reset_token(多分) など様々な場所で使える。(authenticated?メソッドの抽象化・メタプログラミング)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)

  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),reset_sent_at: Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # 試作feedの定義
  # 完全な実装は次章の「ユーザーをフォローする」を参照
  # すべてのユーザーがフィードを持つので、feedメソッドはUserモデルで作るのが自然
  def feed
  # 下の「?」があることで、SQLクエリに代入する前にidがエスケープされるため、SQLインジェクション（SQL Injection）と呼ばれる深刻なセキュリティホールを回避できます
    Micropost.where("user_id = ?", id)
  end



  private

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email.downcase!
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

end