
=begin

=end

require 'logger' 

LOGGER = Logger.new(STDERR)

class NERTagAbstractor
  def initialize(filename)
    @dict = Hash.new { |h,k| h[k] = [] }
    open(filename).each do |line|
      arr = line.chomp.split(",").map{|e| e.strip}
      @dict[arr.last] = arr
    end
  end
  def is_subclass_of?(tag, clas)
    unless @dict[tag]
      raise RuntimeError
      return false
    end
    return true if @dict[tag].include?(clas)
    return false
  end
  def top_level_tag(tag)
    #p @dict[tag]
    if @dict[tag].first == nil
      return "O"
    else
      return @dict[tag].first
    end
  end
  def second_level_tag(tag)
    return @dict[tag][1]
  end
  def generalize(tag)
    raise NotImplementedError
  end
end

class TopLevelAbstractor < NERTagAbstractor
  def generalize(orig)
    #LOGGER.warn(orig)
    return "text" if orig == "text"
    return "O" if orig == "O"
    bio, t = orig.split("-")
    top = top_level_tag(t)
    return "O" if top == "O"
    return [bio, top].join("-")
  end
end

require 'optparse'

params = ARGV.getopts("h:")

if params["h"]
  @generalizer = TopLevelAbstractor.new(params["h"])
else
  raise RuntimeError
end

while line = gets()
  line = line.chomp
  if line == ""
    puts
    next
  end
  arr = line.chomp.split("\t")
  tag = arr.shift
  features = arr
  
  if features == nil
    puts 
    next
  else
    newtag = @generalizer.generalize(tag)
    puts [newtag, features].join("\t")
  end
end
