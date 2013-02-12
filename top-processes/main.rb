load "alfred_feedback.rb"

def top
	results = `top -o cpu -l 2 -n 11 -stats pid,ppid,user,cpu,time,rsize,vsize,command`
	lines = results.split(/\n/)
	entries = []
	lines.reverse_each do |line|
	  if line.length == 0
	    break
	  else
	    entries << line
	  end
	end
	processes = []
	entries.slice(0..-2).reverse_each do |entry|
	  columns = entry.split
	  processes << {:line => entry, :pid => columns[0], :ppid => columns[1], :user => columns[2], :cpu => columns[3], :time => columns[4], :rsize => columns[5], :vsize => columns[6], :command => columns[7..-1].join(' ') }
	end
	processes.delete_if { |x| x[:command] == 'top' }
end

feedback = Feedback.new

top().each do |process|
	feedback.add_item({:title => process[:command], :arg => process[:pid], :subtitle => "PID #{process[:pid]} CPU #{process[:cpu]} Time #{process[:time]} Memory #{process[:rsize]}/#{process[:vsize]}"})
end

puts feedback.to_xml
