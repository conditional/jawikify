require 'mecab'
require 'oj'
Oj.default_options = {:mode => :compat }

@tagger = MeCab::Tagger.new()
cnt = 0
while line = gets()
  STDERR.puts cnt if cnt % 100000 == 0
  obj = Oj.load(line)
  obj["abstract_mecab"] = @tagger.parse(obj["abstract"])
  puts Oj.dump(obj)
  cnt += 1
end
