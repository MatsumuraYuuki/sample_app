class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      reset_session     # ログインの直前に必ずこれを書くこと。セッション固定攻撃への対策
      log_in user       #sessions_helper.rbのメソッド
      redirect_to user  #redirect_to user_url(user)と同等。つまり@userでも振る舞いは同じ.7.4.1記載
    else
    flash.now[:danger] = "Invalid email/password combination"
     render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other 
    # RailsでTurboを使うときは、このように303 See Otherステータスを指定することで、DELETEリクエスト後のリダイレクトが正しく振る舞うようにしなければならない
  end

end
