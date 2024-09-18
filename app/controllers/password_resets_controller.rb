class PasswordResetsController < ApplicationController
  # authenticated?メソッドを使って、パスワード再設定者が正当なユーザーであることを確認します。そのためにbeforeフィルタを使い、editアクションとupdateアクションのどちらの場合も正当な@userであることを要求する
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  #（1）パスワード再設定の有効期限が切れていないかへの対応
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    #(3)新しいパスワードと確認用パスワードが空文字列になっていないか（ユーザー情報の編集ではOKだった）
    if params[:user][:password].empty? 
      @user.errors.add(:password, "can't be empty")
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params)      #(4)新しいパスワードが正しければ、更新する
      @user.update_attribute(:reset_digest, nil)
      reset_session
      log_in @user
      #ブラウザの「戻る」ボタンを数回押してパスワード再設定フォームを他人が見つけたら、それを使いパスワード更新に成功してしまう可能性がある。その対応↓でパスワードの再設定に成功したらダイジェストをnilになるように変更
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity #(2)無効なパスワードであれば失敗させる(失敗理由も表示)
    end
  end


  private

  # パラメータの中から、userオブジェクトに関連する部分だけを取得。これにより、不要な（または意図しない）パラメータをフィルタリング。
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  # 正しいユーザーかどうか確認する
  def valid_user
    unless (@user && @user.activated? &&
            @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

  # トークンが期限切れかどうか確認する
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end
end
