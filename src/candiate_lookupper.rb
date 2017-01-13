# -*- coding: utf-8 -*-
require 'json'
require 'kyotocabinet'

class CandidateLookupper
  def initialize(cg_filename)
    @cg = KyotoCabinet::DB::new
    @cg.open(cg_filename, KyotoCabinet::DB::OREADER)
  end
  # nilを返すこともある
  def lookup(mention)
    candidates = JSON.load(@cg.get(mention))
    return candidates
  end
end

