# encoding: UTF-8
load 'menu_items.rb'

search_term = ARGV[0].nil? ? "" : ARGV[0].downcase.encode('utf-8', 'utf-8-mac')

if (search_term.length > 1)
	puts MenuItems.generate_xml(search_term, MenuItems.generate_items())
end
