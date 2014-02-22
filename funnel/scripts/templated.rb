#!/usr/bin/ruby
# by Brett Terpstra 2014 (http://brettterpstra.com)

input = STDIN.read

template = input.match(/(\?\:)?##(\d+),(\d+)##/)
if template.nil?
  puts input
  exit
end

display = template[1].nil? ? true : false

modifier = input.scan(/(##([+\-])?(\d+)##)/)
modified = []

unless modifier.empty?

  modifier.each {|x|
    inc = 0

    padding = x[2].match(/^(0+)([1-9](\d+)?)?/)
    unless padding.nil? or x[2] =~ /^0$/
      padding = "%0#{padding[0].length.to_s}d"
    else
      padding = "%d"
    end

    if x[1] =~ /\+/ or x[1].nil?
      inc = x[2].to_i
    else
      inc = x[2].to_i * -1
    end

    modified.push([Regexp.escape(x[0]), inc, padding])
  }
end

padding = template[2].match(/^(0+)([1-9](\d+)?)?/)

unless padding.nil? or template[2] =~ /^0$/
  padding = "%0#{padding[0].length.to_s}d"
else
  padding = "%d"
end
count_start = template[2].to_i
count_end = template[3].to_i
duration = (count_end - count_start) + 1
duration.times do
  sub = display ? padding % count_start.to_i : ''
  out = input.sub(/#{Regexp.escape(template[0])}/,sub)
  modified.each {|mod|
    out.sub!(/#{mod[0]}/,(mod[2] % (count_start.to_i + mod[1].to_i)).to_s)
  }
  puts out
  count_start += 1
end
