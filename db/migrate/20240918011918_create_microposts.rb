class CreateMicroposts < ActiveRecord::Migration[7.0]
  def change
    # create_table を使うとき、 t.text :contentやt.references :user〜〜 は、新しいテーブルを作成すると同時にカラムを定義するために使われます。つまり、テーブルを作成する際に、そのテーブルにどのようなカラムを持たせるかを指定している部分です。
    create_table :microposts do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    # ↓インデックスに追加することで、user_idに関連付けられたすべてのマイクロポストを作成時刻の逆順で取り出しやすくなり、パフォーマンスが向上します。
    add_index :microposts, [:user_id, :created_at]
  end
end
