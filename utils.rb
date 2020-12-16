require "digest/md5"
require "securerandom"

def sanitize(text)
  dame = /<|>|"|#|`|'|\*|\\|;|:/
  iiyo = {"<"=>"&#060", ">"=>"&#062", "\""=>"&#034", "#"=>"&#035", "`"=>"&#096", "'"=>"&#039", "\*"=>"&#042", "\\"=>"&#092", ";"=>"&#059", ":"=>"&#058"}

  text = text.gsub(dame){iiyo[$&]}

  return text
end

def trim(text)
  return text.gsub(/\s+/, "")
end

def get_hashed(text)
  return Digest::MD5.hexdigest(text)
end

def random_text()
  r = Random.new
  return get_hashed(r.bytes(20))
end

class Object
  def is_number?
    to_f.to_s == to_s || to_i.to_s == to_s
  end

  def is_time?
    is_number?
  end

  def is_empty?
    to_s == ""
  end

  def has_specialchar?
    /[^a-zA-Z0-9]/.match(to_s) != nil
  end

  def has_specialchar_without_underbar?
    /[^a-zA-Z0-9_]/.match(to_s) != nil
  end

  def has_whitespace?
    /\s+/.match(to_s) != nil
  end
end

puts "has_specialchar"
puts "Al019:" + "#{"Al019".has_specialchar?}"
puts "123_456:" + "#{"123_456".has_specialchar?}"
puts "---"
puts "has_specialchar_without_underbar"
puts "123_456:" + "#{"123_456".has_specialchar_without_underbar?}"
puts "---"
puts "has_whitespace?"
puts "1234:" + "#{"1234".has_whitespace?}"
puts "12 34:" + "#{"12 34".has_whitespace?}"
