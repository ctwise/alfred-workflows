require './alfred_feedback.rb'
query = ''
if ARGV.length > 0
	query = ARGV[0].downcase
end
home = `echo $HOME`.chomp
raw_bookmarks = `plutil -p "#{home}/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist" | grep "bookmark"`.lines
bookmarks = {}
raw_bookmarks.each do |line| 
	tokens = line.split("\"")
	bookmark_id = tokens[1].split(/[{}]/)[1]
	bookmark_key = tokens[1].split(/\./)[3]
	bookmark_value = tokens[3]
	bookmarks[bookmark_id] = (bookmarks[bookmark_id] || {})
	if bookmark_key != nil
		bookmarks[bookmark_id][bookmark_key.to_sym] = bookmark_value
	end

	title = bookmarks[bookmark_id][:title]
	if bookmark_key == 'label' && bookmark_value.length > 0
		bookmarks[bookmark_id][:title] = bookmark_value
	end
	if bookmark_key == 'hostname' && title == nil
		bookmarks[bookmark_id][:title] = bookmark_value
	end
end
desktops = bookmarks.reject {|entry| entry.nil? }.collect { |key, value| value[:title] }
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
