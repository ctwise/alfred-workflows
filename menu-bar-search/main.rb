require 'digest/md5'
require 'yaml'
require 'tempfile'
load 'alfred_feedback.rb'
load 'menu_items.rb'

search_term = ARGV[0].nil? ? "" : ARGV[0].downcase

application = `osascript frontapp.scpt | sed -E 's/application process //'`.strip
application_location = `mdfind "kMDItemDisplayName=#{application}.app"`.strip
cache_name = "/tmp/menu-cache-#{Digest::MD5.hexdigest(application_location)}.yaml"

if File.exists?(cache_name)
  items = YAML.load_file(cache_name)
  xml = MenuItems.generate_xml(search_term, application, application_location, items)
  # `ruby background.rb #{cache_name} > /dev/null 2>&1 &`
else
  items = MenuItems.generate_items()
  File.open(cache_name, 'w') { |out| out.write(items.to_yaml) }
  xml = MenuItems.generate_xml(search_term, application, application_location, items)
end

puts xml
