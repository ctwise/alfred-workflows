arg = ARGV[0]
cmd = ARGV[1] =~ /cmd=true/

RCTL = '/usr/local/sbin/rabbitmqctl'

home = ENV['HOME']
plist = "#{home}/Library/LaunchAgents/homebrew.mxcl.rabbitmq.plist"

if arg == 'management'
	`open 'http://localhost:15672/'`
elsif arg == 'running'
	if cmd 
		results = `#{RCTL} -q stop_app 2> /dev/null`
	else
		results = `launchctl unload "#{plist}"`
	end
elsif arg == 'running_but_stopped'
	if cmd
		results = `launchctl unload "#{plist}"`
	else
		results = `#{RCTL} -q start_app 2> /dev/null`
	end
elsif arg == 'not_running'
	results = `launchctl load "#{plist}"`
	results = `launchctl start 'homebrew.mxcl.rabbitmq'`
elsif arg.start_with?('/queues/')
	`open 'http://localhost:15672/\##{arg}'`
end
