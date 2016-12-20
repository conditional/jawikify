
require 'json'

#class Tagger

def open(cls)
  return "<span class='#{cls}'>"
end

def close()
  return "</span>"
end

puts <<EOS
<html><head>
<style>
.Product {
  color: green
}
.Location {
  color: red
}
.Organization {
  color: blue
}
</style>
</head>
<body>
EOS

while line = gets()
  o = JSON.load(line)
  bb = ""
  o['ner']['mecab'].each.with_index do |sentence, idx|
    status = nil
    buffer = ""
    sentence.each_line.with_index do |token, jdx|
      surface = token.split("\t").first
      t  = o["ner"]["chunk"][idx][jdx]
      if t == "O" || t == nil
        buffer << close() if status != nil
        buffer << surface
        status = nil
      elsif t.split("-").first == "B"
        status = t.split("-")[1]
        buffer << open(status)
        buffer << surface
      elsif t.split("-").first == "I"
        buffer << surface
      end
    end
    bb << buffer 
  end
  puts "<div>" + bb + "</div>"
end


puts <<EOS
</body>
</html>
EOS
