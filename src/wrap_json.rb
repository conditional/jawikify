
require_relative 'to_json.rb'

require 'logger'
require 'tempfile'

text = ""
while line = gets()
  text << line
end

temp = Tempfile.open("ner_temp")
temp.puts <<EOS
<?xml version="1.0" encoding="utf-8"?>
<DOC>
<ID>DUMMY</ID>
<TEXT>
#{text}
</TEXT>
</DOC>
EOS

logger = Logger.new(STDERR)
@ex = ToJSON.new(logger)
puts @ex.do_with_io(temp.open())
