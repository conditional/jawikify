# -*- coding: utf-8 -*-
=begin
標準入力からjsonを読んで、
kyotocabinet の書庫をコンパイルする。

-k : インデックスするキーの名前
-t : 書き出す書庫の名前
=end

require 'kyotocabinet'
require 'json'
require 'optparse'
require 'logger'

@logger = Logger.new(STDERR)
params = ARGV.getopts("t:")

dbfilename = params['t']

db = KyotoCabinet::DB::new

unless db.open(dbfilename, KyotoCabinet::DB::OCREATE | KyotoCabinet::DB::OWRITER)
  puts "db open error"
  exit(1)
end

cnt = 0 
while line = gets()
  @logger.warn(cnt) if cnt % 1000 == 0
  begin
    a = line.chomp.split(" ")
  rescue
    next
  end
  k = a.shift
  v = a.map(&:to_f).join(" ")
  #puts k, v
  db.set(k, v)
  cnt += 1
end
db.close()

