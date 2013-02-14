# encoding: utf-8

require 'net/http'
require 'rexml/document'
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

term = CGI::escape(ARGV[0])

suggestions = []

url = "http://google.com/complete/search?output=toolbar&q=#{term}"

# get the data as a string
xml_data = get_with_timeout(url, 1)

if xml_data.length > 0
	# extract information
	suggestion_doc = REXML::Document.new(xml_data)
	suggestion_doc.elements.each('toplevel/CompleteSuggestion') do |ele|
	   text = ele.elements['suggestion'].attributes['data']
	   count = ele.elements['num_queries'].attributes['int']
	   suggestions << {:text => text, :count => count}
	end
end

if suggestions.length == 0 || suggestions[0][:text].downcase != ARGV[0].downcase
  suggestions.unshift({:text => ARGV[0], :count => "none"})
end

feedback = Feedback.new
suggestions.each do |suggestion|
  count_str = suggestion[:count] == "none" ? "" : " (#{suggestion[:count]})"
  feedback.add_item({:uid => "suggest #{term}", :title => suggestion[:text], :subtitle => "Search Google for '#{suggestion[:text]}'#{count_str}", :arg => suggestion[:text]})
end

puts feedback.to_xml
