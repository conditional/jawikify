

if __FILE__ == $0
  require 'logger'
  require 'optparse'
  require 'multiset'
  require 'json'
  
  params = ARGV.getopts("g:p:")
  
  require_relative "../label_abstraction.rb"
  list_name = params['h'] || "data/list-Name20161220.txt"
  @generalizer = TopLevelAbstractor.new(list_name)
  
  @gold = params['g'] || "offsets"
  # "linked" || "gold_linked"
  @predicted = params['p'] || "linked"
  
  while line = gets()
    o = JSON.parse(line)
    gold      = o['ner'][@gold]
    predicted = o['ner'][@predicted]
    
    correct_set = Multiset.new()
    gold.each do |mention|
      mention_tag = @generalizer.generalize_category(mention["tag"])
      next if mention_tag == "text" or mention_tag == "O"
      correct_set << mention['title']
    end
    
    predicted_set = Multiset.new()
    predicted.each do |sent|
      sent.each do |mention|
        predicted_set << mention['title']
      end
    end
    
    if params['v']
      p correct_set
      p predicted_set
    end
    match = (predicted_set & correct_set).size
    puts ["#", correct_set.size, predicted_set.size, match].join(" ")
    
    precision = (predicted_set & correct_set).size / predicted_set.size.to_f
    recall    = (predicted_set & correct_set).size / correct_set.size.to_f
    
    f1 = 2 * (precision*recall) / (precision + recall)
    puts [precision.round(3), recall.round(3), f1.round(3)].join(" ")
  end
end

