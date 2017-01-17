# coding: utf-8

TH = (ARGV.shift || 0.0).to_f

arr = []
while line = gets()
  arr << line.split(/\s/)
end

correct = 0
miss    = 0

correct_nil = 0
miss_nil    = 0

correct_nonnil = 0
miss_nonnil    = 0

# qidでグループ化して、正しいエンティティが紐付いていたらスコアを足す
groups = arr.group_by{|elem|
  #p elem
  elem[2]
}
p groups.length
groups.each do |k,q|

  # 全エンティティに対して低いスコアがある
  # nilの場合
  if q.all?{|e| e[1] == "0"}
    if q.all?{|e| e[0].to_f < TH }
      #correct += 1
      correct_nil += 1
      #next
    else
      #miss += 1
      miss_nil += 1
    end
    next
  end
  
  # スコアが最大のエンティティが正解であれば +1
  if q.max_by {|e| e[0].to_f }[1] == "1"
    #correct += 1
    correct_nonnil += 1
  else
    #miss += 1
    miss_nonnil += 1
  end
  
end

miss = miss_nonnil + miss_nil
correct = correct_nonnil + correct_nil

puts ["TH: ", TH].join("\t")
puts ["all: ",correct, miss, correct / (correct+miss).to_f].join("\t")
puts ["nil: ",correct_nil, miss_nil, correct_nil / (correct_nil+miss_nil).to_f].join("\t")
puts ["nnil: ", correct_nonnil, miss_nonnil, correct_nonnil / (correct_nonnil+miss_nonnil).to_f].join("\t")
