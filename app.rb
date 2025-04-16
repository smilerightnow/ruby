## I installed nokogiri: gem install nokogiri

require 'nokogiri'
require 'open-uri'
require 'json'

## this selector works on a browser after document load on different layouts, but will not work here because of Javascript not being rendered, and google changes its layout after load:
## document.querySelectorAll("div:not([style*='relative']):not([style*='border-radius']) img[src*='jpeg']:not([alt=''])")


doc = Nokogiri::HTML5(URI.open('./files/van-gogh-paintings.html'))

artworks = []
doc.css("img[src*='gif']:not([alt=''])").each do |img|
	if img.parent["href"] # check if img has parent with link
	
		name = img["alt"]
		link = "https://www.google.com/" + img.parent["href"]
		extension = img.next.children[1].content
		
		if img.parent.children.size == 2 and img["id"] 
			id = img["id"]
			image = ""
			
			doc.css("script").each do |script|
				if script.inner_html.include?(id)
					image = script.inner_html.match(/var s='(.*?)';/)[1]
				end
			end
					
		elsif img.parent.children.size == 2 and not img["id"]
			image = img["data-src"]
		end
		
		if not extension.empty?
			artworks.push({"name" => name, "extensions" => [extension], "link" => link, "image" => image})
		else
			artworks.push({"name" => name, "link" => link, "image" => image})
		end
	end
end

to_save = {"artworks": artworks}

File.open("result.json", 'w') do |file|
  file.write(JSON.pretty_generate(to_save))
end
