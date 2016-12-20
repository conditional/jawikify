require 'mecab'
require 'oj'
Oj.default_options = {:mode => :compat }

@tagger = MeCab::Tagger.new()

while line = gets()
  obj = Oj.load(line)
  arr = []
  obj["ner"]["sentences"].each do |s|
    #STDERR.puts s
    arr <<  @tagger.parse(s)
  end
  obj["ner"]["mecab"] = arr
  puts Oj.dump(obj)
end
