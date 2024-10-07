class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    # create_table を使うとき、t.string :name や t.string :email は、新しいテーブルを作成すると同時にカラムを定義するために使われます。つまり、テーブルを作成する際に、そのテーブルにどのようなカラムを持たせるかを指定している部分です。
    create_table :users do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
