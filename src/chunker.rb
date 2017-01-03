# -*- coding: utf-8 -*-

require 'crfsuite'
=begin

ner_featuresを用いて系列ラベリングを行い，
ner_resultに吐き出す，結果は文字インデックスを添え字とした配列

ruby tweet_label.rb -m modelfilename < tweet.json > tweet_json.result

=end

class TweetLabeler
  def initialize(model_filename)
    @tagger = Crfsuite::Tagger.new()
    @tagger.open(model_filename)
    #@marginal_tags = marginal_tags
  end
  
  def do(o, from, to)
    f = o["ner"][from] # array
    o["ner"][to] = []
    f.each do |sentence|
      xseq = Crfsuite::ItemSequence.new()
      sentence.each_line do |line|
        next if line.chomp.length == 0
        item = Crfsuite::Item.new()
        line.chomp.split("\t").each do |i|
          ar = i.split(":")
          if ar.length == 2
            # weighted attribute
            item << Crfsuite::Attribute.new(ar.first, ar.last.to_f)
          else
            item << Crfsuite::Attribute.new(i)
          end
        end
        xseq << item
      end
      @tagger.set(xseq)
      # decode
      yseq = @tagger.viterbi()
      o["ner"][to] << yseq.map{|e|e}
    end
    return o
  end
end


if __FILE__ == $0
  require 'optparse'
  require 'json'
  params = ARGV.getopts("m:t:f:")
  model_filename = params['m']
  from = params["f"] || "ner_features"
  to = params["t"] || "ner_result"
  
  @labeler = TweetLabeler.new(model_filename)
  while line = STDIN.gets()
    o = JSON.load(line)
    puts @labeler.do(o, from, to).to_json
  end
end
