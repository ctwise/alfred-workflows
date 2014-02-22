# encoding: UTF-8
require "json"
load "alfred_feedback.rb"

items = Feedback.new

if ARGV.length > 0
  filter_name = ARGV[0]
  filters = JSON.parse( IO.read('filters.json') )
  found_filters = filters.find_all{|obj| obj[0].upcase.include?(filter_name.upcase) }.sort {|a, b| a[0].upcase <=> b[0].upcase}
  found_filters.each do |filter|
    items.add_item({:title => filter[0], :subtitle => filter[1], :arg => filter[1]})
  end
end

puts items.to_xml