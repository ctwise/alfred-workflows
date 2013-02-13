require 'rubygems'
require 'sqlite3'
load "alfred_feedback.rb"

query = ARGV[0].strip.downcase

output = `osascript get_recent_documents.applescript`

merge = {}

output.split("\n").each_slice(2) do |lines|
	merge[lines[1]] = lines[0]
end

db = SQLite3::Database.new(File.expand_path("~/Library/Application Support/Alfred 2/Databases/knowledge.alfdb"))
rows = db.execute(("select path from recentdocs order by ts desc"))

rows.each do |row|
	merge[row[0]] = File.basename(row[0])
end

feedback = Feedback.new

merge.each do |entry|
	if query.length == 0 || entry[1].downcase.include?(query)
		feedback.add_item({:title => entry[1], :subtitle => entry[0], :arg => entry[0], :icon => {:type => "fileicon", :name => entry[0]}})
	end
end

puts feedback.to_xml
