# SearchLink 2.0 by Brett Terpstra 2014 (http://brettterpstra.com)
# Free to use and modify, please maintain attribution
require 'net/https'
require 'rubygems'
require 'json'
require 'cgi'

if RUBY_VERSION.to_f > 1.9
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

# You can optionally copy any config variables to a text file
# at "~/.searchlink" to make them permanent during upgrades
# Values found in ~/.searchlink will override defaults in
# this script

# if File.exists? (File.expand_path("~/.searchlink"))
#   config = IO.read(File.expand_path("~/.searchlink"))
#   eval config
# end

# set to true to force inline links
inline ||= false

# set to true to add titles to links based on site title
include_titles ||= false

# change this to set a specific country for search (default US)
country_code ||= "US"

# set to true to include a random string in ref titles
# allows running SearchLink multiple times w/out conflicts
prefix_random ||= false

# append affiliate link info to iTunes urls, empty quotes for none
# example:
# itunes_affiliate = "&at=10l4tL&ct=searchlink"
itunes_affiliate ||= "&at=10l4tL&ct=searchlink"

# to create Amazon affiliate links, set amazon_partner to:
# [tag, camp, creative]
# Use the amazon link tool to create any affiliate link and examine
# to find the needed parts. Set to false to return regular amazon links
# example: amazon_partner = ["bretttercom-20","1789","390957"]
amazon_partner ||= ["tedwisecom-20","1789","9325"]

# To create custom abbreviations for Google Site Searches,
# add to (or replace) the hash below.
# "abbreviation" => "site.url",
# This allows you, for example to use [search term](!bt)
# as a shortcut to search brettterpstra.com. Keys in this
# hash can override existing search triggers.
custom_site_searches ||= {
  "tw" => "tedwise.com",
  "md" => "www.macdrifter.com"
}

input = STDIN.read

inline = true if input.scan(/\]\(/).length == 1

class String
  def clean
    self.gsub(/\n+/,' ').gsub(/"/,"&quot").gsub(/\|/,"-").strip
  end
end

def wiki(terms)
  uri = URI.parse("http://en.wikipedia.org/w/api.php?action=query&format=json&prop=info&inprop=url&titles=#{CGI.escape(terms)}")
  req = Net::HTTP::Get.new(uri.request_uri)
  req['Referer'] = "http://tedwise.com"
  req['User-Agent'] = "SearchLink (http://tedwise.com)"
  res = Net::HTTP.start(uri.host, uri.port) {|http|
    http.request(req)
  }
  result = JSON.parse(res.body)

  if result
    result['query']['pages'].each do |page,info|
      return [info['fullurl'],info['title']]
    end
  end
end

def zero_click(terms)
  url = URI.parse("http://api.duckduckgo.com/?q=#{CGI.escape(terms)}&format=json&no_redirect=1&no_html=1&skip_disambig=1")
  res = Net::HTTP.get_response(url).body
  result = JSON.parse(res)
  if result
    definition = result['Definition'] || false
    definition_link = result['DefinitionURL'] || false
    wiki_link = result['AbstractURL'] || false
    title = result['Heading'] || false
    return [title, definition, definition_link, wiki_link]
  else
    return false
  end
end

def itunes(entity, terms, dev, aff = '', country_code = "US")
  url = URI.parse("http://itunes.apple.com/search?term=#{CGI.escape(terms)}&country=#{country_code}&entity=#{entity}&attribute=allTrackTerm")
  res = Net::HTTP.get_response(url).body
  json = JSON.parse(res)
  if json['resultCount'] && json['resultCount'] > 0
    result = json['results'][0]
    case entity
    when /(mac|iPad)Software/
      output_url = dev && result['sellerUrl'] ? result['sellerUrl'] : result['trackViewUrl']
      output_title = result['trackName']
    when /(musicArtist|song|album)/
      case result['wrapperType']
      when 'track'
        output_url = result['trackViewUrl']
        output_title = result['trackName'] + " by " + result['artistName']
      when 'collection'
        output_url = result['collectionViewUrl']
        output_title = result['collectionName'] + " by " + result['artistName']
      when 'artist'
        output_url = result['artistLinkUrl']
        output_title = result['artistName']
      end
    end
    if dev
      return [output_url, output_title]
    else
      return [output_url + aff, output_title]
    end
  else
    return false
  end
end

def lastfm(entity, terms)
  url = URI.parse("http://ws.audioscrobbler.com/2.0/?method=#{entity}.search&#{entity}=#{CGI.escape(terms)}&api_key=2f3407ec29601f97ca8a18ff580477de&format=json")
  res = Net::HTTP.get_response(url).body
  json = JSON.parse(res)
  if json['results']
    begin
      case entity
      when 'track'
        result = json['results']['trackmatches']['track'][0]
        url = result['url']
        title = result['name'] + " by " + result['artist']
      when 'artist'
        result = json['results']['artistmatches']['artist'][0]
        url = result['url']
        title = result['name']
      end
      return [url, title]
    rescue
      return false
    end
  else
    return false
  end
end

def google(terms, define = false)
  uri = URI.parse("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&filter=1&rsz=small&q=#{CGI.escape(terms)}")
  req = Net::HTTP::Get.new(uri.request_uri)
  req['Referer'] = "http://brettterpstra.com"
  res = Net::HTTP.start(uri.host, uri.port) {|http|
    http.request(req)
  }
  json = JSON.parse(res.body)
  if json['responseData']
    result = json['responseData']['results'][0]
    return false if result.nil?
    output_url = result['unescapedUrl']
    if define && output_url =~ /dictionary/
      output_title = result['content'].gsub(/<\/?.*?>/,'')
    else
      output_title = result['titleNoFormatting']
    end
    return [output_url, output_title]
  else
    return false
  end
end

def amazon_affiliatize(url, amazon_partner)
  return url unless amazon_partner
  if url =~ /http:\/\/www.amazon.com\/(?:(.*?)\/)?dp\/([^\?]+)/
    title = $1
    id = $2
    tag = $3
    az_url = "http://www.amazon.com/gp/product/#{id}/ref=as_li_ss_tl?ie=UTF8&camp=#{amazon_partner[1]}&creative=#{amazon_partner[2]}&creativeASIN=#{id}&linkCode=as2&tag=#{amazon_partner[0]}"
    return [az_url, title]
  else
    return [url,'']
  end
end

links = {}
footer = ''
prefix = prefix_random ? ("%04d" % rand(9999)).to_s + "-" : ''
highest_marker = 0

input.scan(/\[(?:#{prefix}-)?(\d+)\]: /).each do |match|
  highest_marker = $1.to_i if $1.to_i > highest_marker
end

if input =~ /\[(.*?)\]\((.*?)\)/

  input.gsub!(/\[(.*?)\]\((.*?)\)/) do |match|
    link_text = $1
    link_info = $2
    search_type = ''
    search_terms = ''

    if link_info =~ /^(?:\!(.+) )?"(.*?)"$/
      if $1.nil?
        search_type = 'g'
      else
        search_type = $1
      end
      search_terms = $2
    elsif link_info =~ /^\!/
      search_word = link_info.match(/^\!(.+)/)
      search_type = search_word[1] unless search_word.nil?
      search_terms = link_text
    elsif link_text && link_text.length > 0 && (link_info.nil? || link_info.length == 0)
      search_type = 'g'
      search_terms = link_text
    else
      search_type = false
      search_terms = false
    end

    custom_site_searches.each {|k,v|
      if search_type == k
        search_type = 'g'
        search_terms = "site:#{v} #{search_terms}"
      end
    } if search_type && search_terms && search_terms.length > 0

    url = false
    title = false

    case search_type
    when /^a$/
        az_url, title = google("site:amazon.com #{search_terms}", false)
        url, title = amazon_affiliatize(az_url, amazon_partner)

    when /^g$/ # google lucky search
        url, title = google(search_terms)

    when /^wiki$/
        url, title = wiki(search_terms)

    when /^def$/ # wikipedia/dictionary search
        # title, definition, definition_link, wiki_link = zero_click(search_terms)
        # if search_type == 'def' && definition_link != ''
        #   url = definition_link
        #   title = definition.gsub(/'+/,"'")
        # elsif wiki_link != ''
        #   url = wiki_link
        #   title = "Wikipedia: #{title}"
        # end
        url, title = google("define " + search_terms, true)

    when /^masd?$/ # Mac App Store search (mas = itunes link, masd = developer link)
        dev = search_type =~ /d$/
        url, title = itunes('macSoftware',search_terms, dev, itunes_affiliate, country_code)
  # Stopgap:
  #when /^masd?$/
  # url, title = google("site:itunes.apple.com Mac App Store #{search_terms}")
  # url += itunes_affiliate

    when /^itud?$/ # iTunes app search
        dev = search_type =~ /d$/
        url, title = itunes('iPadSoftware',search_terms, dev, itunes_affiliate, country_code)

    when /^s$/ # software search (google)
        url, title = google("(software OR app OR mac) #{search_terms}")
        link_text = title if link_text == ''

    when /^isong$/ # iTunes Song Search
        url, title = itunes('song', search_terms, false)

    when /^iart$/ # iTunes Artist Search
        url, title = itunes('musicArtist', search_terms, false)

    when /^ialb$/ # iTunes Album Search
        url, title = itunes('album', search_terms, false)

    when /^lsong$/ # Last.fm Song Search
        url, title = lastfm('track', search_terms)

    when /^lart$/ # Last.fm Artist Search
        url, title = lastfm('artist', search_terms)
    else
      if search_terms
        if search_type =~ /.+?\.\w{2,4}$/
            url, title = google("site:#{search_type} #{search_terms}")
        else
            url, title = google(search_terms)
        end
      end
    end


    if url
      link_text = title if link_text == '' && title
      if inline
        title && include_titles ? %Q{[#{link_text}](#{url} "#{title.clean}")} : %Q{[#{link_text}](#{url})}
      else
        if links.has_key? url
          marker = prefix + ("%03d" % (links[url].to_i + highest_marker))
        else
          links[url] = prefix + ("%03d" % (links.length + 1 + highest_marker)).to_s
          footer += %Q{\n[#{links[url]}]: #{url}}
          footer += %Q{ "#{title.clean}"} if title && include_titles
        end

        if title
          %Q{[#{link_text}][#{links[url]}]}
        else
          %Q{[#{link_text}](#{url})}
        end
      end
    else
      match
    end
  end

  if inline
    print input
  else
    puts input
    puts footer
  end

else
  url, title = google(input)
  if include_titles
    print %Q{[#{input.strip}](#{url} "#{title.clean}")}
  else
    print %Q{[#{input.strip}](#{url})}
  end
end

