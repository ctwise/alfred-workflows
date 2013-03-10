# encoding: utf-8

require 'net/http'
require 'cgi'
load 'alfred_feedback.rb'

def get_with_timeout(url, timeout_value)
	uri = URI.parse(url)

    http = Net::HTTP::new(uri.host, uri.port)
    http.open_timeout = timeout_value
    http.read_timeout = timeout_value

    begin
	    response = http.request(Net::HTTP::Get.new(uri.request_uri))
	    response.body
    rescue
    	# Do nothing
    	""
    end
end

def between(text, first_char, last_char) 
	firstpos = text.index(first_char)
	lastpos = text.index(last_char, firstpos + 1)
	text[(firstpos + 1)..(lastpos - 1)]
end

original_term = ARGV[0]
term = CGI::escape(ARGV[0])

suggestions = []

url = "http://mvnrepository.com/search.html?query=#{term}"

# get the data as a string
html_data = get_with_timeout(url, 1)
results = []

if html_data.length > 0
	# extract information
	html_lines = html_data.split(/\n/)
	looking_for = 1
	description = ""
	title = ""
	url = ""
	html_lines.each_with_index do |line, i|
		if looking_for == 1 && line =~ /<p class="result">/
			looking_for = 2
			description = ""
			title = ""
			url = ""
		elsif looking_for == 2 && line =~ /<a href=/
			url = "http://mvnrepository.com#{between(line, '"', '"')}"
			looking_for = 3
		elsif looking_for == 3 && line =~ /class="result-title"/
			title = between(line, '>', '<')
			looking_for = 4
		elsif looking_for == 4
			if line =~ /<a href/
				looking_for = 1
				description = description.strip
				if description == '<br/>'
					description = ''
				else
					pos = description.index('<br/>')
					description = description[0..(pos - 1)]
				end
				results << {:title => title, :description => description, :url => url}
			else
				description += line
			end
		end
	end
end

if results.size == 0
	results << {:title => original_term, :description => "Search mvnrepository for #{original_term}", :url => "http://mvnrepository.com/search.html?query=#{term}"}
end

feedback = Feedback.new
results.each do |result|
	feedback.add_item(:title => result[:title], :subtitle => result[:description], :arg => result[:url])
end

puts feedback.to_xml

