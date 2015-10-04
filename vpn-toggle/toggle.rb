vpn_name = ARGV[0]
status = system("scutil --nc show \"#{vpn_name}\" | grep Disconnected > /dev/null")
if status
	system("scutil --nc start \"#{vpn_name}\"")
else
	system("scutil --nc stop \"#{vpn_name}\"")
end
