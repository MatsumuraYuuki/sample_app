class StaticPagesController < ApplicationController
  def home
    if logged_in?
      # user.microposts.buildはuserに紐付いた新しいMicropostオブジェクトを返すメソッド
      # フォーム変数fをf.objectとすることによって、関連付けられたオブジェクトにアクセスすることができます
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end
    
  def help
  end

  def about
  end

  def contact
  end
end
