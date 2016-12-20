# -*- coding: utf-8 -*-

require 'nokogiri'
require 'json'

require 'oj'
Oj.default_options = {:mode => :compat }

class ToJSON
  def initialize(logger = Logger.new(STDERR))
    @logger = logger
  end

  def clean_newline(xml)
    xml.xpath("/DOC/TEXT").first.children.each do |elem|
      elem.remove if elem.text == "\n"
      if elem.text?
        #elem.content = elem.content.gsub(/^\n/, "")
        elem.content = elem.content.gsub(/\n/, "")
      end
    end
    return xml
  end

  def do_with_io(io)
    xml = Nokogiri::XML(io.read)
    xml = clean_newline(xml)
    offsets = compile_offset(xml)
    sentences = sentence_splitter(xml)
    #puts offsets
    #puts sentences
    return (Oj.dump({
      "ner" => {
        "sentences" => sentences,
        "offsets"  => offsets
      }
    }))
  end
  
  def do(filename)
    do_with_io(open(filename))
  end
  
  def is_sentence(stack)
    return true if stack.join.match(/(\n|\?|？|\!|！|。)$/)
  end
  
  def compile_offset(xml)
    offset = 0;
    offsets = xml.xpath("/DOC/TEXT").first.children.map{|e|
      ret = {
        "surface" => e.text, "tag" => e.name,  
        "offset" => { "start" => offset,  "end" => (offset + e.text.length - 1) , "length" => e.text.length}
      } ;
      offset += e.text.length;
      ret
    }
    return offsets
  end
  
  def sentence_splitter(xml, output = STDOUT)
    text = xml.xpath("/DOC/TEXT").text
    chars = text.chars
    stack = []
    idx = 0
    output = []
    while chars.length > 0
      stack << chars.shift
      if is_sentence(stack)
        start_idx = idx-(stack.join.length-1)
        #文頭の\nを置換する必要がある？
        output << stack.join
        stack = []
      end
      idx += 1
    end
    return output 
  end
  
end

if __FILE__ == $0
  require 'logger'
  logger = Logger.new(STDERR)
  @ex = ToJSON.new(logger)
  filename = ARGV.shift
  if filename
    puts @ex.do(filename)
  else
    puts @ex.do_with_io(STDIN)
  end
end
