class SessionsController < ApplicationController
  def new
    # debugger
  end


  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      forwarding_url = session[:forwarding_url]
      reset_session     # ログインの直前に必ずこれを書くこと。セッション固定攻撃への対策
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      log_in user       #sessions_helper.rbのメソッド
      redirect_to forwarding_url || user #事前にプロフィールページ以外を開こうとしてたらforwarding_urlを使いそちらに移動。それないならプロフィールページに移動
    else
    flash.now[:danger] = "Invalid email/password combination"
     render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other 
    # RailsでTurboを使うときは、このように303 See Otherステータスを指定することで、DELETEリクエスト後のリダイレクトが正しく振る舞うようにしなければならない
  end

end
