# -*- coding: utf-8 -*-

=begin
鈴木辞書を転置して、 mention で引けるようにする。
mention => 
=end
require 'oj'

Oj.default_options = {:mode => :compat}

out_filename = ARGV.shift

mention_to_title = Hash.new { |h,k| h[k] = [] }

cnt = 0 
while line = gets()
  puts cnt if cnt % 10000 == 0
  o = Oj.load(line)
  title = o['entry']
  if o["page_property"] == "Normal"
    o["link_anchor"].each do |l|
      mention = l["anchor"]
      mention_to_title[mention] << {"title"=>title, "count" =>l["count"]}
    end
  end
  cnt += 1
end

puts "load finished"
file = open(out_filename, "w")

mention_to_title.each do |mention, entities|
  sorted = entities.sort_by {|o| -o['count']}
  # calc sum of mentions
  total = sorted.inject(0){|sum, o| sum + o['count']}
  # calc p_e_x (relative frequencies of entities)
  sorted_pex_annotated = sorted.map do |o|
    o['p_e_x'] = o['count'] / total.to_f
    o 
  end
  file.puts(Oj.dump({ "mention"=>mention,"candidates"=>sorted_pex_annotated}))
end
file.close
