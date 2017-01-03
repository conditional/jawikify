require 'json'
require 'kyotocabinet'

class FE_w2v
  def setup(args)
    args['filename'] 
  end
  def extract(obj)
    return []
  end
end

class FE_entity_vector
  def setup(args)
  end
  def extract(obj)
    return []
  end
end

class FE_BoW
  def setup(args)
  end
  def extract(obj)
    o = []
    obj['abstract_mecab'].each_line do |e|
      o << e.split("\t").first
    end
    puts o 
    return o.uniq
  end
end

class FeatureExtractorContainer
  include Enumerable
  def initialize
    @fe = []
  end
  def add(fe)
    @fe << fe
  end
  def each(&block)
    @fe.each(&block)
  end
end

container = FeatureExtractorContainer.new()
#container.add(FE_entity_vector.new)
container.add(FE_BoW.new())
cnt = 0
while line = gets()
  puts cnt if cnt % 10000 == 0
  o = JSON.load(line)
  o['features'] = []
  container.each do |fe|
    o['features'] << {name: fe.class.name, vector: fe.extract(o)}
  end
  puts o.to_json
  cnt += 1
end
