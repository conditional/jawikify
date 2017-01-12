# coding: utf-8

# 知識ベースの mecab から
# IDFを計算して吐き出す

require 'oj'
require 'logger'

@logger = Logger.new(STDERR)

db = Hash.new(0.0)

cnt = 0
while line = gets()
  @logger.warn(cnt / 1588284.to_f) if cnt % 1000 == 0 
  o = Oj.load(line)
  local_db = {}
  o['abstract_mecab'].each_line do |line|
    t = line.split("\t").first
    next if local_db[t]
    local_db[t] = true
    db[t] += 1
  end
  cnt += 1 
end

@logger.warn("loaded!!, db size: #{db.size}, number of document if #{cnt}")

db.each do |k,v|
  puts Oj.dump( { k: k, idf: Math.log(cnt / v) })
end

