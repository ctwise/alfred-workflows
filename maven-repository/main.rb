# encoding: utf-8

require 'net/http'
require 'cgi'
load 'alfred_feedback.rb'

def damerauLevenshteinDistance(source, target)
    if source.nil? || source.length == 0
        if target.nil? || target.length == 0
            return 0
        else
            return target.length
        end
    elsif target.nil? || target.length == 0
        return source.length
    end 
 
    score = Array.new(source.length + 2) { Array.new(target.length + 2, 0) }
 
    inf = source.length + target.length
    score[0][0] = inf
    for i in (0..source.length)
        score[i + 1][1] = i
        score[i + 1][0] = inf
    end
    for j in (0..target.length)
        score[1][j + 1] = j
        score[0][j + 1] = inf
    end
 
    sd = {}
    (source + target).split("").each do |letter|
        if !sd.has_key?(letter)
            sd[letter] = 0
        end
    end

    for i in 1..source.length
        db = 0
        for j in 1..target.length
            i1 = sd[target[j - 1].chr]
            j1 = db
 
            if source[i - 1] == target[j - 1]
                score[i + 1][j + 1] = score[i][j]
                db = j
            else
                score[i + 1][j + 1] = [score[i][j], [score[i + 1][j], score[i][j + 1]].min].min + 1
            end
 
            score[i + 1][j + 1] = [score[i + 1][j + 1], score[i1][j1] + (i - i1 - 1) + 1 + (j - j1 - 1)].min
        end
 
        sd[source[i - 1].chr] = i
    end
 
    return score[source.length + 1][target.length + 1]
end

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
                path_components = url.split('/')
                the_path = "#{path_components[-2]} >> #{path_components[-1]}"
				results << {:title => "#{title} (#{the_path})", :description => description, :url => url, :distance => damerauLevenshteinDistance(original_term, title)}
			else
				description += line
			end
		end
	end
end

if results.size == 0
	results << {:title => original_term, :description => "Search mvnrepository for #{original_term}", :url => "http://mvnrepository.com/search.html?query=#{term}"}
end

results = results.sort {|a, b| a[:distance] <=> b[:distance] }

feedback = Feedback.new
results.each do |result|
	feedback.add_item(:title => result[:title], :subtitle => result[:description], :arg => result[:url])
end

puts feedback.to_xml

