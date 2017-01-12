# -*- coding: utf-8 -*-

require 'json'
require 'optparse'

class IOBDecoder
  def initialize()
    @stack = []
    @type  = nil
    @extracted = []
  end
  def flush()
    ret = @stack.join("")
    @stack = []
    return [ret, @type.dup]
  end
  def decode(t, token, idx, jdx)
    return unless t
    tag = t.split("-").first
    if tag == "B" 
      # stackに中身が存在
      if @stack.size != 0
        @extracted << self.flush() 
      end
      @type = t.split("-")[1]
      @stack << token
    elsif tag == "I"
      @stack << token
    else # O 
      @extracted << self.flush() if @stack.size != 0
      @type = nil
    end
  end
  def extracted
    return @extracted
  end
end

while line = gets()
  o = JSON.load(line.chomp)
  o["ner"]["extracted"] = []
  o["ner"]["mecab"].each.with_index do |sentence, idx|
    d = IOBDecoder.new()
    sentence.each_line.with_index do |token, jdx|
      #p token
      t = o["ner"]["chunk"][idx][jdx]
      d.decode(t, token.split("\t").first, idx, jdx)
    end
    o["ner"]["extracted"]  << d.extracted
  end
  puts o.to_json
end
