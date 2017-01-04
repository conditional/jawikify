# -*- coding: utf-8 -*-
require 'json'
require 'kyotocabinet'
require_relative 'word_index.rb'
require 'matrix'

class FE_Base
  def initialize(args)
    @type = 'sparse'
  end
  attr_reader :type
  def extract(obj)
    
  end
  def teardown(args)
    
  end
end

# w2vの平均ベクトルを返す
class FE_w2v_averaging < FE_Base
  def initialize(args)
    @db = KyotoCabinet::DB::new
    @db.open(args['vector_filename'], KyotoCabinet::DB::OREADER)
    @dim = args['vector_dimention']
    @type = 'dense'
  end
  def extract(obj)
    # 300次元の0ベクトル
    ret = Vector.elements([0.0] * @dim)
    cnt = 0
    obj['abstract_mecab'].each_line do |e|
      w = e.split("\t").first
      v = @db.get(w)
      next unless v
      ret += Vector.elements(v.split(" ").map(&:to_f))
      cnt += 1.0
    end
    ret = ret / cnt if cnt > 0
    return ret
  end
  def teardown(args)
    @db.close()
  end
end

# BoWのスパースベクトルを返す
class FE_BoW < FE_Base
  def initialize(args)
    @filename = args['id_filename']
    @ids = Word2ID.new(@filename)
    @type = 'sparse'
  end
  def extract(obj)
    o = []
    obj['abstract_mecab'].each_line do |e|
      o << e.split("\t").first
    end
    ret = o.uniq.map{|w| @ids.id(w)}
    return ret
  end
  def teardown(args)
    @ids.dump(@filename)
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
  def teardown(args)
    self.each { |e| e.teardown(args) }
  end
end

require 'logger'
require 'optparse'

params = ARGV.getopts("t:d:v:")
args={}
args['id_filename']      = params['t'] || 'word_ids.tsv'
args['vector_filename']  = params['v'] || 'data/charanda04.300.kch'
args['vector_dimention'] = (params['d'] || 300).to_i

container = FeatureExtractorContainer.new()
#container.add(FE_entity_vector.new)
container.add(FE_BoW.new(args))
#container.add(FE_w2v_averaging.new(args))

@logger = Logger.new(STDERR)
cnt = 0

at_exit {
  container.teardown(args)
}

while line = gets()
  @logger.warn(cnt) if cnt % 1000 == 0
  o = JSON.load(line)
  o['features'] = []
  container.each do |fe|
    o['features'] << {name: fe.class.name, vector: fe.extract(o),type:fe.type}
  end
  puts o.to_json
  cnt += 1
end
