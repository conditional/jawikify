require 'json'

ret = {
  "ner" => {
    "sentences" => [],
    "offsets" => []
  }
}
while line = gets()
  ret["ner"]["sentences"] << line.chomp
end
puts JSON.dump(ret)
