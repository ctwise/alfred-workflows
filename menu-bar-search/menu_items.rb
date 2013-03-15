module MenuItems

  def generate_items()
    menu_items = `osascript enumerate.scpt | sed -E 's/of application "System Events", /\\'$'\\n/g' | grep -E '^menu item "' | sed -E 's/ of menu bar 1.+$//g'`
    items = menu_items.split("\n").collect do |menu_item| 
      menu_path = []
      buffer_match = /\".*?\"(.*)/.match(menu_item)
      if !buffer_match.nil?
        buffer = buffer_match[1]
        File.open('/tmp/buffer.txt', 'w') {|f| f.write(buffer) }
        while buffer.length > 0
          section = / of menu \"(.*?)\" of menu item \"(.*?)\"/.match(buffer)
          if section.nil?
            section = / of menu ([0-9]*) of menu item ([0-9]*)/.match(buffer)
          end
          if section.nil?
            section = / of menu \"(.*?)\" of menu bar item \"(.*?)\"/.match(buffer)
          end
          if section.nil?
            section = / of menu ([0-9]*) of menu bar item ([0-9]*)/.match(buffer)
          end
          if section.nil?
            buffer = ""
          else
            buffer = buffer[(section[0].length)..-1]
            menu_path << section[1]
          end
        end

        {:name => /^menu item \"(.*?)\"/.match(menu_item)[1], 
          :line => menu_item[/\"(.*)/],
          :menu_bar => / of menu bar item \"(.*?)\"$/.match(menu_item)[1],
          :path => menu_path.reverse.join(' > ') 
        }
      end
    end
    items
  end

  def generate_xml(search_term, application, application_location, items)
    found_items = items
    if search_term.length > 0
      found_items = items.find_all { |item| "#{item[:path]} > #{item[:name]}" =~ /#{search_term}/i }
    end

    # remove menu items that have child menu items
    # nothing will happen when you click a parent menu
    found_items.each do |p|
        child_items = found_items.find_all { |c| "#{p[:path]} > #{p[:name]}" == "#{c[:path]}" }
        if child_items.size > 0
            found_items.delete_at(found_items.index(p))
        end  
    end

    feedback = Feedback.new
    found_items.each do |item|
      icon = {:type => "fileicon", :name => application_location}
      app = application
      if item[:menu_bar] == 'Apple'
        icon = {:name => "apple-icon.png"}
        app = "System"
      end
      feedback.add_item({:title => item[:name], :arg => item[:line], :uid => "#{app} menu '#{item[:path]}'", :subtitle => "#{app} menu '#{item[:path]}'", :icon => icon})
    end

    feedback.to_xml
  end

  module_function :generate_xml
  module_function :generate_items
end

