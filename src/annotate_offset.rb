# -*- coding: utf-8 -*-

require 'oj'
Oj.default_options = {:mode => :compat }

class OffsetDB
  def initialize(offsets)
    @db = offsets
  end
  def get_tag(offset)
    # dbを読んでいって、オフセットが一致するところのタグを付与する
    # 与えられたindexが開始位置より大きく、終了位置より小さいときにそのタグを付与
    @db.each do |o|
      if o["offset"]["start"] <= offset && o["offset"]["end"] >= offset
        # もし開始位置ぴったりで、textタグでないときは
        if o["offset"]["start"] == offset && o["tag"] != "text"
          return "B-" + o["tag"]
        end
        if o["tag"] != "text"
          return "I-" + o["tag"] 
        end
      end
    end
    return "O"
  end
end

while line = gets()
  obj = Oj.load(line)
  c = obj["ner"]
  
  @offsetDB = OffsetDB.new(obj["ner"]["offsets"])
  
  offset = 0
  buffer = []
  # array of mecab fragments
  c["nemecab"] = []
  tag_now = "text"
  c["mecab"].each.with_index do |s, idx|
    buf = ""
    if s == "EOS\n"
      st, e = offset , offset 
      offset
      buffer << [s.chomp,st,e, "text" ].join(",") + "\n"
      #buffer << [s.chomp,st,e, @offsetDB.get_tag(st) ].join(",") + "\n"
      next
    end
    
    s.each_line do |morph|
      w = morph.split("\t").first
      if morph != "EOS\n"
        st, e = offset , offset + w.length
        offset += w.length
      else
        st, e = offset , offset
        offset
      end
      if morph == "EOS\n"
        buf << [morph.chomp,st,e, "text" ].join(",") + "\n"
      else
        buf << [morph.chomp,st,e, @offsetDB.get_tag(st) ].join(",") + "\n"
      end
      #c["sentence"][idx].length
    end
    buffer << buf
    buf = ""
  end
  #c["nemecab"] = buffer
  obj["ner"]["nemecab"] = buffer
  
  puts Oj.dump(obj)
end
