#
# Gets a user's full contextual stream and writes it to HTML
#
#
require 'rubygems'
require 'bundler/setup'
require 'epic-geo'


#Find the document on the server
def retrieve_file(name)

	tweets = {}

	root_path = "/home/kena/geo_user_collection/"

	#Get the subcategory
	if name[0] =~ /[[:alpha:]]/
		alph = name[0].downcase
	else
		alph = 'non'
	end

	user = name.downcase

	(1..6).to_a.map!{|num| "geo#{num}"}.each do |section|
		if File.exists? "#{root_path}#{section}/user_data/#{alph}/#{user}-contextual.json"
			file_path = "#{root_path}#{section}/user_data/#{alph}/#{user}-contextual.json"
			in_stream  = File.open(file_path,'r')
			break
		end
	end

	#Now read the stream and return the Hash

	begin
		reg_count = 0
		geo_count = 0
		in_stream.each do |line|
			tweet = JSON.parse(line.chomp)
        	
        	if tweet['coordinates']
				geo_count += 1
			end
			reg_count +=1

			tweets << {:date =>tweet["created_at"], :text=>tweet["text"] }
          
		end
    	puts "----------Geo Ratio for #{user}: #{geo_count} / #{reg_count}---------------\n"
    rescue
    	p $!
    	puts "Stream may not have existed for: #{user}"
    end

    return tweets
end

#====================== Runtime down here


filename = "lisuhc"

#Prepare an HTML File
html_export = HTML_Writer.new("../exports/#{filename}.html")
html_export.write_header('HTML Export of user search')


users = ["lisuhc"]

users.each do |handle|
	tweets = retrieve_file(handle)
	this_content = {:name => handle, :content=>tweets}
	html_export.add_content(this_content)
end 

#Finally, close the files...
html_export.write_navigation("User List")
html_export.write_content
html_export.close_file
