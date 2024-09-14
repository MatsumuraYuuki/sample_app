class ApplicationMailer < ActionMailer::Base
  # rails generate mailerコマンドを実行すると自動的に作成。ApplicationMailer は、すべてのメーラー（たとえば UserMailer）が継承するクラスで、共通の設定やロジックを定義するために使用されます。

  default from: "absol57434@gmail.com"
  layout "mailer"
  # 注: 本番環境でメール送信を行う（11.4）場合は、リスト 11.11のuser@realdomain.com を自分が使っているメールアドレスに必ず変更してください。
end
