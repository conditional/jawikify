
require 'json'
require 'kyotocabinet'
require 'logger'
require 'optparse'

params = ARGV.getopts("t:d:v:")


class DisambiguateStrategy
  def disambiguate(candidates, context)
    return nil
  end
end

class MostFrequentDisambiguator < DisambiguateStrategy
  def disambiguate(candidates, context)
    
  end
end

class Linker
  def initialize(cg_filename, kb_filename)
    @cg = KyotoCabinet::DB::new
    @db.open(cg_filename, KyotoCabinet::DB::OREADER)
    @kb = KyotoCabinet::DB::new
  end
  def lookup(mention)
    
  end
  def teardown()
    @cg.close()
    @kb.close()
  end
end

linker = Linker.new()
disambiguate_strategy = 

at_exit{
  linker.teardown()
}

while line=gets()
  o = JSON.load(obj)
  o['ner']['extracted'].each do |sentence|
    sentence.each do |mention|
      
    end
  end
end
