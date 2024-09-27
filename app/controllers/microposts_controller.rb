class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    #ファイルをモデルに関連付ける。ユーザーがアップロードしたファイルをデータベースに保存し、関連するモデルとリンクさせる
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home', status: :unprocessable_entity
    end
  end

  #correct_userで@micropostを定義済み(before_action :correct_user）
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # エッジケース(滅多に起こらないがユーザーが遭遇する可能性があるバグ)でテスト内でリファラーURLがnilになる可能性があるので、リファラーURLがnilの場合はデフォルトURLにリダイレクトさせる。
    if request.referrer.nil?
      redirect_back_or_to(root_url, status: :see_other)
    else
      redirect_back_or_to(root_url, status: :see_other)
    end
  end

  private

    def micropost_params
      # マイクロポストのcontent属性だけがWeb経由で変更可能
      params.require(:micropost).permit(:content, :image)
    end


    # 下の方法にはセキュリティ上のメリットもあります。あるユーザーが別のユーザーのマイクロポストを削除しようとしても、nilが返されるので自動的に失敗します。
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url, status: :see_other if @micropost.nil?  
    end
end
