load 'alfred_feedback.rb'

vpnlist = `osascript vpn_list.scpt`.lines.sort

feedback = Feedback.new
vpnlist.each do |entry|
	(name, kind) = entry.chomp.split('|')
	if kind == '0' || kind == '10' || kind == '11' || kind == '13' || kind == '16'
		description = "Connect to #{name}"
		icon = "connect.png"
		status = !system("scutil --nc show \"#{name}\" | grep Disconnected > /dev/null")
		if status
			description = "Disconnect from #{name}"
			icon = "disconnect.png"
		end
		feedback.add_item({:title => name, :subtitle => description, :arg => name, :icon => {:type => "default", :name => icon}})
	end
end
puts feedback.to_xml
