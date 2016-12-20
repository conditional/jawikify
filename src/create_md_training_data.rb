
require 'rexml/document'
filename = ARGV.shift

doc = REXML::Document.new(open(filename))

puts doc

puts doc.elements["DOC/TEXT/*"].each do |e|
  
end

