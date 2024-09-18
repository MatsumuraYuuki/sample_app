class UserMailer < ApplicationMailer
  # メールの送信処理を記述するクラスです。ここに、account_activation と password_reset のメールの内容や送信先を定義します。


  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
    # mailはメソッド。UserMailerクラス内で定義されているこのメソッドは、ActionMailerモジュールによって提供されており、メールの送信先(to)、件名(subject)を指定することができます。
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
