class AddAdminToUsers < ActiveRecord::Migration[7.0]
  def change
    # add_column は 既存のテーブルに新しいカラムを追加するときに 使います。
    add_column :users, :admin, :boolean, default: false #←明示的にデフォルトでは管理者になれないのを示す
  end
end
