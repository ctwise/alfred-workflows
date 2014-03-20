load "alfred_feedback.rb"

RCTL = '/usr/local/sbin/rabbitmqctl'
started = true
running = true
results = `#{RCTL} -q status 2> /dev/null`
if results =~ /Error: unable to connect to node/
	running = false
	started = false
else
	started = results =~ /\{pid,/
	running = results =~ /\{rabbit,/
end

vhosts = `#{RCTL} -q list_vhosts 2> /dev/null`.lines.collect {|line| line.chomp}
queues = []
vhosts.each do |host|
	results = []
	if host == '/'
		results = `#{RCTL} -q list_queues 2> /dev/null`.lines.collect {|line| line.chomp}
	else
		results = `#{RCTL} -q list_queues -p #{host} 2> /dev/null`.lines.collect {|line| line.chomp}
	end
	results.each do |queue| 
		items = queue.split
		if items.size > 1
			queues << [host == '/' ? "%2F" : host, items[0], items[1]]
		end
	end
end

feedback = Feedback.new

feedback.add_item(:title => 'Open management web page', :arg => 'management')
if started && running
	feedback.add_item(:title => "RabbitMQ is running and accepting requests", :subtitle => "Stop RabbitMQ, CMD Stop accepting requests", :arg => "running")
elsif started && !running
	feedback.add_item(:title => "RabbitMQ is running but is NOT ACCEPTING requests", :subtitle => "Start accepting requests, CMD Stop running", :arg => "running_but_stopped")
else
	feedback.add_item(:title => "RabbitMQ is NOT RUNNING and is NOT ACCEPTING requests", :subtitle => "Start RabbitMQ", :arg => "not_running")
end
queues.each do |queue|
	feedback.add_item(:title => "Queue #{queue[0]}:#{queue[1]} - #{queue[2]} messages", :arg => "/queues/#{queue[0]}/#{queue[1]}",
		:subtitle => "Open management page")
end


puts feedback.to_xml