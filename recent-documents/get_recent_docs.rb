# encoding: UTF-8
require 'rubygems'
load "alfred_feedback.rb"

query = (ARGV[0] || '').strip.downcase

output = `osascript get_recent_documents.scpt`

rows = []

output.force_encoding("utf-8").split("\n").each_slice(2) do |lines|
	rows << lines[1]
end

db_results = `php sql.php "#{File.expand_path('~/Library/Application Support/Alfred 2/Databases/knowledge.alfdb')}"`

rows << db_results.force_encoding("utf-8").strip.split(/\n/)

# Ignore files in the trash and preference panes
rows = rows.flatten.uniq.find_all {|value| !value.include?('/.Trash/') && !value.end_with?('.prefPane')}

feedback = Feedback.new

rows.each do |entry|
	basename = File.basename(entry)
	exists = File.exists?(entry)
	if exists && (query.length == 0 || basename.downcase.include?(query))
		feedback.add_item({:title => basename, :subtitle => entry, :arg => entry, :icon => {:type => "fileicon", :name => entry}})
	end
end

puts feedback.to_xml
