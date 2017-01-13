# -*- coding: utf-8 -*-

require 'json'
require 'kyotocabinet'
require_relative 'candiate_lookupper.rb'

class DisambiguateStrategyBase
  def disambiguate(candidates, context)
    return nil
  end
end

class MostFrequentDisambiguator < DisambiguateStrategyBase
  def initialize(kb_filename)
  end
  def disambiguate(candidates, context, k_best=5)
    #p candidates
    return candidates.sort_by{|e| -e["p_e_x"]}.first(5)
  end
end

class CosineSimDisambiguator < DisambiguateStrategyBase
  def initialize(kb_filename)
    @kb = KyotoCabinet::DB::new
    @kb.open(kb_filename, KyotoCabinet::DB::OREADER)
  end
  def disambiguate(candidates, context, k_best=5)
    candidates.each do |cand|
      
    end
  end
end

class Linker
  
  def initialize(cg_filename, kb_filename, strategy)
    @cg = CandidateLookupper.new(cg_filename)
    @disambiguator = strategy.new(kb_filename)
  end
  
  def disambiguate(mention, context=nil)
    candidates = @cg.lookup(mention)
    return nil unless candidates
    rankedlist = @disambiguator.disambiguate(candidates["candidates"], context)
    return rankedlist
  end
end


if __FILE__ == $0
  require 'logger'
  require 'optparse'
  
  params = ARGV.getopts("c:k:f:v:")
  from = (params['f'] || 'ner').to_s
  cg_filename = (params['c'] || 'data/master06_candidates.kct') 
  #kb_filename = (params['k'] || 'data/master06_content_mecab_annotated.kch')
  kb_filename = (params['k'] || 'data/master06_content.kch')
  vocab_filaneme = (params['v'] || 'word_ids.tsv') 
  
  linker = Linker.new(cg_filename, kb_filename, MostFrequentDisambiguator)
  #disambiguate_strategy = 
  
  at_exit{
    #linker.teardown()
  }
  
  while line=gets()
    o = JSON.load(line)
    o['ner']['linked'] = o['ner']['extracted'].dup
    
    o['ner']['extracted'].each.with_index do |sentence, i|
      sentence.each.with_index do |mention, j|
        o['ner']['linked'][i][j] << linker.disambiguate(mention[0])
      end
    end
    puts o.to_json
  end
end
