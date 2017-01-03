# -*- coding: utf-8 -*-
# feature_extraction.rb
#

require 'json'
require 'optparse'
require 'logger'
require 'set'

class FeatureExtractorBase
  def initialize()
  end
  # return Array of String
  def do(tokens, origin, offset)
    # Guard for null index
    return [] if origin + offset >= tokens.length
    return [] if origin + offset < 0
    ret = do_(tokens, origin, offset)
    # 配列でない場合はラップする
    if ret.class == Array
      return ret
    else
      return [ret]
    end
  end
  def do_(tokens, origin, offset)
    raise RuntimeError
  end
  def generate_feature_string(category, label = "true", val=1.0)
    return "#{category}=#{label.gsub(/\n/,'NL')}" if val == 1.0
    return "#{category}=#{label.gsub(/\n/,'NL')}:#{val}"
  end
  alias :gfs :generate_feature_string
end

class FeatureExtractorContainer
  WINDOW_SIZE = 2
  def initialize()
    @extractors = []
  end
  def register(fe)
    @extractors << fe
  end

  # nemecab をパース  
  def preprocess(obj)
    return obj["ner"]["nemecab"].map do |sentence|
      sentence.each_line.to_a.map{|morph|
        surface, features = morph.chomp.split("\t")
        next if features == nil
        features = features.split(",")
        [surface, features]
      }.compact
    end
  end

  def label(tokens, offset)
    return tokens[offset].last.last
  end
  
  # 文書をパース
  def do(obj)
    ret = []
    parsed = preprocess(obj)
    # 各文の各トークンに対して
    parsed.each do |sentence|
      sent_f = []
      sentence.each.with_index do |token, idx| # for each token
        features = []
        features += @extractors.first.do(sentence, idx, 0)
        # 各素性抽出機で
        (-WINDOW_SIZE..WINDOW_SIZE).each do |j|
          @extractors.each do |ex|
            features += ex.do(sentence, idx, j)
          end
        end
        #p features
        sent_f << [label(sentence,idx), features.join("\t") ].join("\t")
      end # sentence
      ret << sent_f.join("\n")
    end # parsed
    return ret.join("\n\n")
  end
  
end

class Gazetteer < FeatureExtractorBase
  def initialize()
  end
end

# 単語それ自体
class Surface < FeatureExtractorBase
  def do_(tokens, origin, offset)
    return gfs("s[#{offset}]", tokens[origin+offset].first)
  end
end

class Char < FeatureExtractorBase
  def do_(tokens, origin, offset)
    ret = []
    tokens[origin+offset].first.each_char do |ch|
      ret << gfs("ch[#{offset}]", ch)
    end
    return ret
  end  
end

class LastChar < FeatureExtractorBase
  def do_(tokens, origin, offset)
    return gfs("lc[#{offset}]", tokens[origin+offset].first[-1])
  end
end

class FirstChar < FeatureExtractorBase
  def do_(tokens, origin, offset)
    return gfs("fc[#{offset}]", tokens[origin+offset].first[0])
  end
end

class MojiType < FeatureExtractorBase
  require 'moji'
  
  def do_(tokens, origin, offset)
    ret = []
    ch = tokens[origin+offset].first[-1]
    ret << gfs("m_l_KATA[#{offset}]")   if Moji.type?(ch, Moji::KATA)
    ret << gfs("m_l_KANA[#{offset}]")   if Moji.type?(ch, Moji::KANA)
    ret << gfs("m_l_KANJI[#{offset}]")  if Moji.type?(ch, Moji::KANJI)
    ret << gfs("m_l_NUMBER[#{offset}]") if Moji.type?(ch, Moji::NUMBER)
    ret << gfs("m_l_Moji[#{offset}]", Moji.type(ch).to_s)
    
    ch = tokens[origin+offset].first[0]
    ret << gfs("m_f_KATA[#{offset}]")   if Moji.type?(ch, Moji::KATA)
    ret << gfs("m_f_KANA[#{offset}]")   if Moji.type?(ch, Moji::KANA)
    ret << gfs("m_f_KANJI[#{offset}]")  if Moji.type?(ch, Moji::KANJI)
    ret << gfs("m_f_NUMBER[#{offset}]") if Moji.type?(ch, Moji::NUMBER)
    ret << gfs("m_f_Moji[#{offset}]", Moji.type(ch).to_s)
    return ret
    #return gfs("lc[#{offset}]", tokens[origin+offset].first[-1])
  end
end

@fe = FeatureExtractorContainer.new()
@logger = Logger.new(STDERR)

params = ARGV.getopts("ot:")
idx = 0

@fe.register( Surface.new() )
#@fe.register( Char.new() )
#@fe.register( LastChar.new() )
#@fe.register( FirstChar.new() )
#@fe.register( MojiType.new() )

#if parmas["g"]  
#end

while line = gets()
  #@logger.warn idx if idx % 100 == 0
  o = JSON.parse(line)
  # 素性抽出したものをjsonに埋め込む
  if params["t"]
    o["ner"][params["t"]] = @fe.do(o).split("\n\n")
    puts o.to_json
  else
    puts @fe.do(o)
  end
  idx += 1
end

unless params["t"]
  # インスタンス区切りのための改行
  puts
end
