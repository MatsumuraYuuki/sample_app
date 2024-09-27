class ApplicationController < ActionController::Base
  include SessionsHelper

  def hello
    render html: "hello, world!"
  end


  private
  # 複数のコントローラで使用するメソッドなので各コントローラが継承するApplicationコントローラに、移す
  # ユーザーのログインを確認する
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url, status: :see_other
    end
  end
end
