require "active_record"
require "sqlite3"
require "securerandom"
require "digest/md5"
require "./utils.rb"

ActiveRecord::Base.configurations = YAML.load_file("database.yml")
ActiveRecord::Base.establish_connection :development

AL_MD5 = "0001"

class Database < ActiveRecord::Base
  self.table_name = "users"
end

class Database_Pomodoro < ActiveRecord::Base
  self.table_name = "pomodoro"
end

def normalize_userid(userid)
  if userid.is_empty?
    raise "ユーザーIDが空欄です。"
  end

  if userid.has_specialchar_without_underbar?
    raise "ユーザーIDはアンダーバー以外の特殊文字を利用できません。"
  end

  if userid.has_whitespace?
    raise "ユーザーIDにスペースを含めることはできません。"
  end

  if sanitize(userid).length > 20
    raise "ユーザーIDが長すぎます。20文字以内にしてください。"
  end

  return sanitize(userid)
end

def normalize_password(password)
  if password.is_empty?
    raise "パスワードが空欄です。"
  end

  if password.has_whitespace?
    raise "パスワードにスペースを利用できません。"
  end

  if sanitize(password).length > 200
    raise "パスワードが長すぎます。200文字以内にしてください。"
  end

  return sanitize(password)
end

def normalize_username(username)
  if username.is_empty?
    raise "ユーザー名が空欄です。"
  end

  if username.has_specialchar_without_underbar?
    raise "ユーサー名はアンダーバー以外の特殊文字を利用できません。"
  end

  if username.has_whitespace?
    raise "ユーザー名でスペースを使えません。"
  end

  if sanitize(username).length > 200
    raise "ユーザー名が長すぎます。200文字以内にしてください。"
  end

  return sanitize(username)
end

# ユーザー関連の処理を行うクラス
class User
  # 指定されたIDのユーザーを操作するためのインターフェイスを提供する
  # todo useridが存在しない場合の処理
  def initialize(userid, password, salt, algorithm)
    # normalize
    userid = normalize_userid(userid)
    password = normalize_password(password)

    # get user
    @user = Database.find(userid)
    if gen_pass(password, salt, algorithm) != @user.password
      raise "パスワードが間違っています。"
    end
    @pomodoro = Database_Pomodoro.where("userid LIKE ?", "%#{userid}%")
  end

  def self.login(userid, password)
    # normalize
    userid = normalize_userid(userid)
    password = normalize_password(password)

    # get data
    user = Database.find(userid)
    return self.new(userid, password, user.salt, user.algorithm)
  end

  def self.create_user(userid, username, password)
    # nomalize
    userid = normalize_userid(userid)
    username = normalize_username(username)
    password = normalize_password(password)

    # register
    u = Database.new
    u.id = userid
    u.name = username

    # パスワードの保存
    r = Random.new
    u.salt = Digest::MD5.hexdigest(r.bytes(20))
    u.algorithm = AL_MD5
    u.password = gen_pass(password, u.salt, u.algorithm)
    u.save
  end

  # ユーザーIDを返す
  def get_userid()
    return @user.id
  end

  # ユーザーの名前を返す
  def get_name()
    return @user.name
  end

  # ユーザーを削除する
  def remove()
    @user.destroy
  end

  #:e ポモドーロを追加
  def add_pomodoro(starttime, endtime, worktype)
    # validation
    if !starttime.is_time? || !endtime.is_time?
      raise "Time Format is invalid."
    end

    puts "#{worktype}"
    if !worktype.is_number?
      raise "worktype must be integer."
    end

    # register
    p = Database_Pomodoro.new
    p.id = "#{SecureRandom.hex(20)}"
    p.userid = "#{self.get_userid()}"
    p.starttime = starttime
    p.endtime = endtime
    p.worktype = worktype
    p.save
  end

  #ユーザーのポモドーロを取得
  def get_pomodoros()
    return Pomodoros.new(self.get_userid())
  end
end

# 単体のポモドーロへのインターフェイスを提供する
class Pomodoro
  def initialize(pomodoro)
    @pomodoro = pomodoro
  end

  def get_id()
    return @pomodoro.id
  end

  def remove()
    @pomodoro.destroy
  end
end

# 複数のポモドーロへのインターフェイスを提供する
class Pomodoros
  #ポモドーロを取得
  def initialize(userid)
    @pomodoro = Database_Pomodoro.where(userid: userid)
    # @pomodoro = @pomodoro.order(endtime: :desc)
  end

  def all()
    l = []
    @pomodoro.each do |p|
      l.push(p)
    end
  end
end

# パスワードの生成
def gen_pass(password, salt, algorithm)
  if algorithm == AL_MD5
    r = Random.new
    hashed = Digest::MD5.hexdigest(salt + password)
    return hashed
  end

  raise "Unknow Algorithm Type"
end

def check_pass(input_password, salt, algorithm, correct_password)
  if algorithm == AL_MD5
    hashed = gen_pass(input_password, salt, algorithm)
    if correct_password == hashed
      return true
    else
      return false
    end
  end
end

# gen_passのテスト
r = Random.new
salt = Digest::MD5.hexdigest(r.bytes(20))
puts "password!"
puts salt
puts "#{gen_pass("password!", "#{salt}", AL_MD5)}"
puts "---"

## ユーザーの作成・ログイン・削除
#User.create_user("foo", "foo", "bar")
#puts "success: create_user"
#puts "userid & name: foo password: bar"
#u = User.login("foo", "bar")
#puts "success: login"
#u.remove()
#puts "success: remove"
#puts "---"

# テストユーザーの作成
# User.create_user("testuser", "testuser", "test")
