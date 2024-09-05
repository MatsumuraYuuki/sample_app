ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper

  # Add more helper methods to be used by all tests here...
  def is_logged_in?
    !session[:user_id].nil?
    # これは、テストのセッションにユーザーがあればtrueを返し、それ以外の場合はfalseを返します
  end

  # テストユーザーとしてログイン(コントローラーの単体テスト)　既存のlog_inメソッドとの混乱を防ぐため、あえてメソッド名をlog_in_asとする
  def log_in_as(user)
    session[:user_id] = user.id
    #sessionメソッドを直接操作して、:user_idキーにuser.idの値を代入
  end
end

class ActionDispatch::IntegrationTest

  # テストユーザーとしてログインする(統合テスト)。統合テストではsessionを直接扱えないので、代わりにSessionsリソースに対してpostを送信
  def log_in_as(user, password:'password', remember_me: '1') #キーワード因数使ってる
    post login_path, params: {session: { email:user.email, 
                                         password: password,
                                         remember_me: remember_me } }
  end
end
