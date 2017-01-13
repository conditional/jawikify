# -*- coding: utf-8 -*-

require 'json'
require 'kyotocabinet'


class StringSimilarity
  require 'levenshtein'
  module Levenshtein
    def self.similarity(str1, str2)
      1 - normalized_distance(str1, str2)
    end
  end

  def calc(_, mention, entity)
    return  Levenshtein.similarity(mention, entity['title']) 
  end
end

class GlobalBoWSimilarity
  
  def initialize(idf_database)
    @idf_database = KyotoCabinet::DB::new
    @idf_database.open(idf_database, KyotoCabinet::DB::OREADER)
  end
  
  def idf(t)
    r = @idf_database[t]
    return 0.0 unless r
    return JSON.load(r)['idf'] || 0.0
  end
  
  def calc(source_document, _, entity)
    
    source = Hash.new(0.0)
    source_document['nemecab'].each do |sentence|
      sentence.each do |token|
        t =  token.split("\t").first
        source[t] += idf(t)
      end
    end
    
    e = Hash.new(0.0)
    entity['abstract_mecab'].each do |token|
      t = token.split("\t").first
      e[t] += idf(t)
    end
  end
    
  # 内積
  def dot(v1, v2)
    s = 0.0
    v1.each do |k,v|
      s += v2[k] 
    end
    return s
  end
  
  # cosine
  def calc_cosine(s,e)
    s_norm = Math.sqrt(s.injet(0.0) {|sum, (k, v)| sum + v * v})
    e_norm = Math.sqrt(e.injet(0.0) {|sum, (k, v)| sum + v * v})
    return dot(s,e) / s_norm * e_norm
  end
  
end

class EntityPopularity
  def calc(doc, mention, entity)
    return entity['p_e_x']
  end
end

if __FILE__ == $0
  require 'logger'
  require 'optparse'
  params = ARGV.getopts("k:i:")
  args={}
  # 知識ベース(mention -> candidates)
  args['kb_filename']       = params['k'] || 'word_ids.tsv'
  # IDF データベース
  args['idf_filename']      = params['i'] || 'word_ids.tsv'
  metrics = []
  
  metrics << GlobalBoWSimilarity.new(args['idf_filename'])
  metrics << StringSimilarity.new()
  metrics << EntityPopularity.new()
  
  qid = 0
  while line = gets()
    o = JSON.laod(line)
    # 文書のベクトル表現
    document_representation = create_tf_idf_vector(o)
    o['mention'].each do |mention|
      
      candidate(mention).each do |e|
        label = 2
        if e == mention.correct
          label = 1
        end
        val = []
        metrics.each do |metric|
          val << metric.calc(o, m, e)
        end
        puts [label, "qid:#{qid}", val.join(" ")].join(" ")
      end
      qid += 1
    end
  end
  
end
