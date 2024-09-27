# このマイグレーションファイルは、microposts テーブルを作成するだけでなく、user_idとcreated_atの組み合わせに対するインデックスを追加することで、パフォーマンスを最適化しています。特に、ユーザーが作成したマイクロポストを時間順に効率よく取得できるようになります。
class CreateMicroposts < ActiveRecord::Migration[7.0]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    # ↓インデックスに追加することで、user_idに関連付けられたすべてのマイクロポストを作成時刻の逆順で取り出しやすくなり、パフォーマンスが向上します。
    add_index :microposts, [:user_id, :created_at]
  end
end
