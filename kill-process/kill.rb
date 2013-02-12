pid = ARGV.first
type = ARGV[1]

processes = `ps ax #{pid}`

process = processes.split("\n")[1]

pid = process[0..4].strip
owner = process[6..10].strip
cmd = process[27..-1].strip
short_cmd = cmd
if short_cmd.length > 35
  short_cmd = "...#{short_cmd[-35..-1]}"
end

`kill #{type} #{pid}` 

puts "#{pid} - #{short_cmd}"
