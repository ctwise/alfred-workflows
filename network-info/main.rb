require 'nokogiri'
require 'date'
load 'alfred_feedback.rb'
load 'parser.rb'

xml_results = `/usr/sbin/system_profiler -xml SPNetworkDataType`

items = Parser::parse(Nokogiri::XML(xml_results))[0]['_items']

ips = []
macs = []

items.each do |item|
	name = item['_name']
	type = item['type']
	interface = item['interface']
	ethernet = item['Ethernet']
	if ethernet
		mac = ethernet['MAC Address']
	end
	addresses = item['ip_address']
	if addresses && addresses.size() > 0
		ip = addresses[0]
	end

	result = {:name => name, :type => type, :interface => interface, :mac => mac, :ip => ip}
	if ip
		ips << result
	end
	if mac
		macs << result
	end
end

feedback = Feedback.new
if ARGV[0] == 'ip'
	external_ip = `dig +short myip.opendns.com @resolver1.opendns.com`.strip
	feedback.add_item({:title => "External IP: #{external_ip}", :subtitle => 'Press Enter to paste, or Cmd+Enter to copy', :arg => external_ip})
	ips.each do |interface|
		ip = interface[:ip]
		name = interface[:name]
		device = interface[:interface]
		feedback.add_item({:title => "#{name} (#{device}) IP: #{ip}", :subtitle => 'Press Enter to paste, or Cmd+Enter to copy', :arg => ip})
	end
else
	macs.each do |interface|
		mac = interface[:mac]
		name = interface[:name]
		device = interface[:interface]
		if !mac.nil? && mac.length > 0
			feedback.add_item({:title => "#{name} (#{device}) MAC: #{mac}", :subtitle => 'Press Enter to paste, or Cmd+Enter to copy', :arg => mac})
		end
	end
end
puts feedback.to_xml