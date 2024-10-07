class AddRememberDigestToUsers < ActiveRecord::Migration[7.0]
  def change
    # add_column は 既存のテーブルに新しいカラムを追加するときに 使います。
    add_column :users, :remember_digest, :string
  end
end
