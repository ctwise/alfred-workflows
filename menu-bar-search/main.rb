# encoding: UTF-8
load 'menu_items.rb'

if RUBY_VERSION.start_with?('1.8')
	class String
		def encode(dst_encoding, src_encoding)
			self
		end
	end
end

search_term = ARGV[0].nil? ? "" : ARGV[0].downcase.encode('utf-8', 'utf-8-mac')

if (search_term.length > 0)
	puts MenuItems.generate_xml(search_term, MenuItems.generate_items())
end
