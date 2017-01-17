
require 'fileutils'

WORK = ARGV.shift 

dest = "#{WORK}/result_json_numbered/"
Dir.glob("#{WORK}/result_json/*-wikified.mention_annotated.json").each.with_index do |filename, idx|
  #suf = filename.split("/").last
  suf = "#{idx}.json"
  FileUtils.cp(filename, dest + suf)
end
