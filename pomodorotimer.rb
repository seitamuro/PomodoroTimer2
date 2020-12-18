require "sinatra"
require "sqlite3"
require "./database/database.rb"
require "./app/app.rb"
require "./utils.rb"
require "uri"

set :environment, :production
set :sessions,
  secret: "pomodoro-timer-is-saikooooo"

# 各種パラメータ・メッセージ
$login_users = {}
NOW_SESSION = random_text();

SESSION_EXPIRED_MESSAGE = "セッションが切れました。ログインしなおしてください。"

module WORKTYPE
  WORK = 0.freeze
  REST = 1.freeze
end

# セッションが現在のものかを検証する
def is_valid_session()
  if session[:is_nowsession] == NOW_SESSION
    return true
  else 
    return false
  end
end

# ログインの検証をする関数
def is_login()
  if session[:is_login] == "1" && is_valid_session()
    return true
  else
    return false
  end
end

# ログアウト
def logout()
  session.clear
end

# ログイン
def login(userid, password)
  u = User.login(userid, password)
  session[:userid] = userid
  session[:username] = u.get_name()
  session[:validation] = random_text()
  session[:is_login] = "1"
  session[:is_nowsession] = NOW_SESSION
  $login_users[userid] = u
end

# ログインの検証とリダイレクトをする関数
def is_login_with_logout(message="")
  if is_login()
    return true
  end

  logout()
  # message = URI.escape(message)
  # redirect "/login?message=#{message}"
  redirect_with_message(message)
end

def redirect_with_message(message)
  message = URI.escape(message)
  redirect "/login?message=#{message}"
end

# ルーティング
get '/' do
  redirect '/login'
end

get '/home' do
  if is_login_with_logout("問題が発生しました。ログインしなおしてください。")
    @username = session[:username]
    erb :home
  end
  
end

get '/login' do
  @message = params[:message]
  erb :login
end

post "/login" do
  begin
  login(params[:userid], params[:password])
  rescue
    redirect_with_message("ユーザーIDかパスワードが間違っています。")
  end

  redirect "/home"
end

get '/logout' do
  logout()
  erb :logout
end

get '/createuser' do
  logout()
  erb :createuser
end

post "/createuser" do
  begin
    User.create_user(params[:userid], params[:username], params[:password])
    login(params[:userid], params[:password])
  rescue RuntimeError => e
    redirect "/createuser?message=#{URI.escape("#{e}")}"
  rescue ActiveRecord::StatementInvalid
    redirect "/createuser?message=#{URI.escape("既に存在するユーザーIDです。別のユーザーIDを利用してください。")}"
  rescue => e
    redirect "/createuser?message=#{URI.escape("新しくユーザーを作成することがでませんでした。もう一度入力してください。")}"
  end
  redirect "/home"
end

get '/timer' do
  if is_login_with_logout(SESSION_EXPIRED_MESSAGE)
    erb :timer
  end
end

get '/log' do
  if is_login_with_logout(SESSION_EXPIRED_MESSAGE)
    @logs = $login_users[session[:userid]].get_pomodoros()
    erb :log
  end
end

post "/submitpomodoro" do
  if is_login()
    puts "#{params[:worktype]}"
    $login_users[session[:userid]].add_pomodoro(params[:starttime], params[:endtime], params[:worktype])
  end
end
