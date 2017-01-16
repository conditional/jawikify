
ref = 0
pred = 0
match = 0

while line = gets()
  next unless line.start_with?("#")
  arr = line.split(" ").map(&:to_i)
  #p arr
  ref += arr[1]
  pred += arr[2]
  match += arr[3]
end

prec = (match / pred.to_f)
recall = (match / ref.to_f)
f = (2 * prec * recall) / (prec + recall)
puts ["ref", "pred", "match" , "prec", "rec", "f1"].join("\t")
puts [ref, pred, match, prec.round(3), recall.round(3), f.round(3)].join("\t")
