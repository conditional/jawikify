arr = []
while line = gets()
  arr << line.split(/\s/)
end

arr.group_by{|elem|
  elem[1]
}.select{|k,v|
  v.any?{|vv| vv[0] == "1"}
}.each {|k,v|
  v.each do |e|
    puts e.join(" ")
  end
}
