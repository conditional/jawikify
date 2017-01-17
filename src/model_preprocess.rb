
arr =  readlines().last.split(" ").map{|e| e.split(":").last}
arr.shift
arr.pop
arr.unshift(0.0)
puts arr.join("\t")
