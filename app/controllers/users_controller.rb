class UsersController < ApplicationController

  # デフォルトでは、beforeフィルターはコントローラ内のすべてのアクションに適用されるので、適切な:onlyオプション（ハッシュ）を渡すことで、制限をかけています。
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy


  def index
    @users = User.paginate(page: params[:page])
    # User.paginate
    # User.paginateは、:pageパラメーターに基いて、データベースからひとかたまりのデータ（デフォルトでは30）を取り出します。したがって、1ページ目はユーザー1から30、2ページ目はユーザー31から60、という具合にデータが取り出されます。
  end


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
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
      # redirect_to @userは user_url(@user)と同等です。
    else
      render 'new', status: :unprocessable_entity
      # 保存が失敗した場合は new テンプレートを再度表示します（このとき、エラーメッセージも表示されす）。
    end
  end

  def edit  #editアクションは、編集フォームを表示するためのアクション
    @user = User.find(params[:id])
  end

  #通常editアクションから送信されるフォームのデータを受け取り、データベースを更新するアクション。createアクションの最初のバージョンと極めて似通っています
  def update 
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end


  private

  #実行結果として、許可されたカラムの値だけを抽出し、ハッシュ形式で呼び出し元に値を返す
  def user_params
    params.require(:user).permit(:name, :email, :password,:password_confirmation)
  end
  # 上のコードでは、許可された属性リストにadminが含まれていないことに注目してください。これにより、任意のユーザーが勝手にアプリケーションの管理者権限を与えることを防止できます



  # beforeフィルタ

  # ログイン済みユーザーかどうか確認
  def logged_in_user
    unless logged_in? #ログインしてない時に処理を実行
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url, status: :see_other
    end
  end

  # 正しいユーザーかどうか確認　current_userメソッドじゃないよ！
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
    #10.29:最終的なcorrect_userの実装 @user == current_userと同義
  end

  # 管理者かどうか確認
  def admin_user
    redirect_to(root_url, status: :see_other) unless current_user.admin?
  end
end
