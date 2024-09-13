class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    # 3つの条件を確認します。1ユーザーが存在する(user)、2まだアカウントが有効化されていない (!user.activated?)、３送信された有効化トークンがユーザーのactivation_digestと一致している 
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # アカウントを有効化し、activated属性をtrueに設定します。また、有効化日時として現在の時間を activated_at に記録します。
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else  #無効だった場合の処理も行われている点にご注目ください。無効はめったにないが念の為
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
