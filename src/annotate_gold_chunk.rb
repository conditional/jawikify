# -*- coding: utf-8 -*-
=begin
ruby src/annotate_gold_chunk.rb -h data/list-Name20161220.txt

gold standard (一般化されていない) データ(nemecab)をうけとって、
chunkというタグにぶっこむ。

=end

require 'json'
require_relative 'label_abstraction.rb'
require 'optparse'
params = ARGV.getopts("h:")
@generalizer = TopLevelAbstractor.new(params["h"])

while line = gets()
  o = JSON.load(line)
  o['ner']['chunk'] = []
  o['ner']['nemecab'].each.with_index do |sentence,i|
    o['ner']['chunk'] << []
    sentence.each_line.with_index do |token, j|
      tag = token.chomp.split(",").last
      abs_tag = @generalizer.generalize(tag)
      unless abs_tag == "text"
        o['ner']['chunk'][i] << abs_tag
      end 
    end
  end
  puts o.to_json
end
