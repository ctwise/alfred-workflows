require './alfred_feedback.rb'
query = ''
if ARGV.length > 0
	query = ARGV[0].downcase
end
home = `echo $HOME`.chomp
raw_desktops = `plutil -p "#{home}/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist" | grep "}\.label\"`.lines
desktops = raw_desktops.collect {|line| line.split("\"")[3]}.sort_by {|value| value.downcase }
if query.length > 0
	desktops = desktops.find_all {|desktop| desktop.downcase.include?(query)}
end
feedback = Feedback.new
if desktops.size() > 0
	desktops.each do |desktop|
		feedback.add_item({:title => desktop, :subtitle => "Open desktop"})
	end
else
	feedback.add_item({:title => 'No matching desktop found', :subtitle => "Can't open desktop", :arg => '##notfound##'})
end
puts feedback.to_xml
