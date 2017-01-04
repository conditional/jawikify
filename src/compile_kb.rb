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
params = ARGV.getopts("k:t:")

dbfilename = params['t']
key        = params['k']

db = KyotoCabinet::DB::new

unless db.open(dbfilename, KyotoCabinet::DB::OCREATE | KyotoCabinet::DB::OWRITER)
  puts "db open error"
  exit(1)
end

at_exit{
  db.close()
}

c = 0
while line = gets()
  o = JSON.load(line)
  @logger.warn(c) if c % 10000 == 0
  k = o[key]
  db.set(k,line)
  c += 1
end


