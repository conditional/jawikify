
require 'json'

class Word2ID
  def initialize(filename = nil)
    @w2id = {}
    if filename && File.exist?(filename)
      self.load(filename)
    else
    end
  end
  
  def id(w)
    unless @w2id[w]
      @w2id[w] = @w2id.size
    end
    return @w2id[w]
  end
  
  def dump(filename)
    open(filename, 'w') do |f|
      @w2id.each do |w,i|
        f.puts [w,i].join("\t")
      end
    end
  end
  
  def load(filename)
    open(filename) do |f|
      while l = f.gets()
        w, i = l.chomp.split("\t")
        @w2id[w] = i.to_i
      end
    end
  end
  
end
