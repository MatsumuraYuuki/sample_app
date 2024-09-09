module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
    # ↑Railsで事前定義済み

    # セッションリプレイ攻撃から保護する
    # 詳しくは https://techracho.bpsinc.jp/hachi8833/2023_06_02/130443 を参照
    session[:session_token] = user.session_token
  end

  # 永続的セッションのためにユーザーを[データベースに]記憶する
  def remember(user)
    user.remember #models/user.rbで定義  トークンを生成してデータベースに保存
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
    # remember(user)メソッドは、user.rememberメソッドを内部で呼び出し、さらにクッキーにトークンやユーザーIDを保存する。
  end

  # 記憶トークンのcookieに対応するユーザーを返す
  def current_user
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      if user && session[:session_token] == user.session_token
        @current_user = user
      end
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
    # このコードは、ユーザーがセッションをまたいでログイン状態を維持できるようにするために、次の二つの方法を使用しています
    #1セッションからユーザーIDを取得する（アクティブなログイン中の場合）。
    #2暗号化されたクッキーからユーザーIDと認証情報を取得する（「ログイン状態を保持する」機能のため）。
  end

  # 渡されたユーザーがカレントユーザーであればtrueを返す:リスト10.27
 def current_user?(user)
   user && user == current_user
 end

    # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
 def forget(user)
   user.forget
   cookies.delete(:user_id) 
   cookies.delete(:remember_token)
 end

 # 現在のユーザーをログアウトする 
 def log_out
    forget(current_user)
    reset_session
    @current_user = nil  #安全のため,このメソッドは、Sessionsコントローラのdestroyアクションで使えます
  end

   def store_location
    # リクエストされたURLを取得し、GETリクエストの場合のみそのURLを返すという処理
    # requestは、Railsで提供されるコントローラ内のオブジェクト。具体的には、requestはActionDispatch::Requestのインスタンスであり、HTTPリクエストの詳細を保持しています。
    session[:forwarding_url] = request.original_url if request.get?
  end
end
