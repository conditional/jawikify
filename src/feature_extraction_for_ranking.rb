# -*- coding: utf-8 -*-

require 'oj'
require 'kyotocabinet'


class StringSimilarity
  require 'levenshtein'
  module ::Levenshtein
    def self.similarity(str1, str2)
      1 - Levenshtein.normalized_distance(str1, str2)
    end
  end

  def calc(_, mention, entity)
    return  Levenshtein.similarity(mention, entity['entry']).round(3)
  end
end

class GlobalBoWSimilarity
  
  def initialize(idf_database)
    @idf_database = KyotoCabinet::DB::new
    @idf_database.open(idf_database, KyotoCabinet::DB::OREADER)
    @cache_entity = {}
    @cache_source = {}
    @cache_sim    = {}
  end
  
  def idf(t)
    #p t
    r = @idf_database.get(t)
    #p r
    return 0.0 unless r
    return Oj.load(r)['idf'] || 0.0
  end

  def source_representation(source_document)
    source = Hash.new(0.0)
    source_document['ner']['nemecab'].each do |sentence|
      sentence.each_line do |token|
        t =  token.split("\t").first
        source[t] += idf(t)
      end
    end
    return source
  end
  
  def entity_representation(entity)
    e = Hash.new(0.0)
    entity['abstract_mecab'].each_line do |token|
      t = token.split("\t").first
      e[t] += idf(t)
    end
    return e
  end

  def calc(source_document, _, entity)
    unless @cache_source[source_document]
      s = source_representation(source_document)
      @cache_source[source_document] = s
    else
      s = @cache_source[source_document]
    end

    unless @cache_entity[entity]
      e = entity_representation(entity)
      @cache_entity[entity] = e
    else
      e = @cache_entity[entity]
    end
    
    return calc_cosine(s,e)
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
    r = @cache_sim[[s,e]]
    return r if r
    #p s,e
    s_norm = Math.sqrt(s.inject(0.0) {|sum, (k, v)| sum + v * v})
    e_norm = Math.sqrt(e.inject(0.0) {|sum, (k, v)| sum + v * v})
    @cache_sim[[s,e]] = (dot(s,e) / s_norm * e_norm).round(3)
    return @cache_sim[[s,e]]
  end
  
end

class EntityPopularity
  def calc(doc, mention, entity)
    return entity['link_from_N']
  end
end

if __FILE__ == $0
  require 'logger'
  require 'optparse'
  params = ARGV.getopts("k:i:c:")
  args={}
  # 知識ベース title -> entity detail
  args['kb_filename']       = params['k'] || 'work/kb.kch'
  # IDF データベース
  args['idf_filename']      = params['i'] || 'data/master06_content_mecab_annotated.idf.kch'
  # mention -> [titles]
  args['cg_filename']       = params['c'] || 'data/master06_candidates.kct'
  
  metrics = []
  metrics << GlobalBoWSimilarity.new(args['idf_filename'])
  metrics << StringSimilarity.new()
  metrics << EntityPopularity.new()
  
  require_relative 'candiate_lookupper.rb'
  @cg = CandidateLookupper.new(args['cg_filename'])
  @kb = CandidateLookupper.new(args['kb_filename'])
  
  qid = 0
  while line = gets()
    o = Oj.load(line)
    # 文書のベクトル表現
    o['ner']['offsets'].each do |mention|
      next if mention['tag'] == 'text'
      #p mention
      candidates =  @cg.lookup(mention['surface'])
      next unless candidates
      candidates['candidates'].each do |e|
        # e: title => 
        ee = @kb.lookup(e['title'])
        #p ee
        label = 2
        if ee['entry'] == mention['title']
          label = 1
        end
        val = []
        metrics.each.with_index do |metric, i |
          val << [i+1, metric.calc(o, mention['surface'], ee)].join(":")
        end
        puts [label, "qid:#{qid}", val.join(" "), "#", mention['surface'], e['title']].join(" ")
      end
      qid += 1
    end
  end
  
end
