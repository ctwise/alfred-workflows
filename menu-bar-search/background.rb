require 'yaml'
load 'menu_items.rb'

cache_name = ARGV[0]
temp_name = "/tmp/menu-cache-background-tmp-#{Process.pid}-#{Time.now.utc.to_s.gsub(/\W/, '')}"
items = MenuItems.generate_items()
File.open(temp_name, 'w') { |out| out.write(items.to_yaml) }
File.rename(cache_name, "#{temp_name}-old")
File.rename(temp_name, cache_name)
File.delete("#{temp_name}-old")