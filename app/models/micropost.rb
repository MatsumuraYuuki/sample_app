class Micropost < ApplicationRecord
  #ユーザーと1対1の関係であることを表す。has_manyはmicropostが複数持つので複数形。belongs_to:userは単数系
  # $rails generate〜にuser:referencesという引数も含めたから追加された
  belongs_to :user
  #has_one_attachedでimageとMicropostモデルを関連付けます。　
  # do |attachable|　←このブロック内で、添付された画像に関する追加の処理を定義します。
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end

  #->というラムダ（lambda）の省略記法を使っています。ラムダは、Procやlambda（もしくは無名関数）と呼ばれるオブジェクトを作成する文法
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  #jpeg,gif,pngという3つのMIMEタイプのいずれかである必要があります。 %w[]は文字列の配列を作成するショトカ
  # message:"xx"　はファイルが指定されたMIMEタイプではなかった場合に表示されるエラーメッセージ
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                      size:         { less_than: 5.megabytes,
                                      message:   "should be less than 5MB" }
end
