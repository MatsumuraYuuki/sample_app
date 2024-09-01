class UsersController < ApplicationController

  def show #id=xのユーザーを表示するページ
    @user = User.find(params[:id])
    # debugger
    # （演習newメソッドに移したがそのままで良いのか分からんので戻した）
  end

  def new #新規ユーザー作成ページ
    @user = User.new
  end

  def create #ユーザーを作成するアクション、form_withのヘルパーによって呼び出される
    @user = User.new(user_params)
    if @user.save
      reset_session
      log_in @user
      redirect_to @user
      flash[:success] = "Welcome to the Sample App!"
      # redirect_to user_url(@user)と同等です。
    else
      render 'new', status: :unprocessable_entity
      # 保存が失敗した場合は new テンプレートを再度表示します（このとき、エラーメッセージも表示されす）。
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,:password_confirmation)
  end
  

end