class AddActivationToUsers < ActiveRecord::Migration[7.0]
  def change
    # add_column は 既存のテーブルに新しいカラムを追加するときに 使います。
    add_column :users, :activation_digest, :string
    add_column :users, :activated, :boolean, default: false
    add_column :users, :activated_at, :datetime
  end
end
