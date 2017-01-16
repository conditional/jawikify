require 'json'

if __FILE__ == $0
  require 'logger'
  require 'optparse'
  params = ARGV.getopts("g:p:")
  gold      = params["g"] || "gold"
  predicted = params["p"] || "chunk"
  
  while line = gets()
    o = JSON.load(line)
    #mecab = o['ner']['mecab'][i]
    #t = o['ner']['mecab'][i][j].split("\t").first
    o['ner'][gold].each.with_index do |sentence, i|
      mecab = o['ner']['mecab'][i].split("\n")
      sentence.each.with_index do |token, j|
        t = mecab[j].split("\t").first
        p = o['ner'][predicted][i][j]
        puts [t, i, j, token, p].join(" ")
      end
      puts
    end
  end
end
