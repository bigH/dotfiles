Pry.config.commands.command(/pbpaste/, 'enter paste mode') do
  tmp = `pbpaste`
  puts "== Pasting from clipboard ==\n#{tmp}\n== Executing ==\n"
  eval tmp
end

Pry.commands.alias_command 'c', 'continue'
Pry.commands.alias_command 's', 'step'
Pry.commands.alias_command 'n', 'next'
Pry.commands.alias_command 'f', 'finish'
Pry.commands.alias_command 'b', 'break'
Pry.commands.alias_command 'x', 'exit-program'

def hdb(msg)
  puts "HIRENDEBUG: #{msg}"
end
