
require 'fileutils'
dest = "data/jawikify_work/"
Dir.glob("data/jawikify_20160310_release/*-wikified.xml").each.with_index do |filename, idx|
  #suf = filename.split("/").last
  suf = "#{idx}.xml"
  FileUtils.cp(filename, dest + suf)
end
