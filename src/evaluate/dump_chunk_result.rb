require 'json'

if __FILE__ == $0
  require 'logger'
  require 'optparse'
  params = ARGV.getopts("g:p:")
  gold      = params["g"] || "gold"
  predicted = params["p"] || "chunk"
  
  while line = gets()
    o = JSON.load(line)
    o['ner'][gold].each.with_index do |sentence, i|
      sentence.each.with_index do |token, j|
        p = o['ner'][predicted][i][j]
        puts [i, j, token, p].join(" ")
      end
      puts
    end
  end
end
