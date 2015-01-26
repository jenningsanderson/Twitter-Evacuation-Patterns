_start =  Time.new(2012,10,22)
_end   =  Time.new(2012,11,14)

#We're running on the server!  here we go!
require_relative '../server_config'
require_relative '../cloud_export/full_contextual_stream'
#Because it's meant to be run on the server

write_directory = './csv_out/'

contextual_stream = FullContextualStreamRetriever.new(
	start_date:  _start,
	end_date:    _end,
	root_path:   "/home/kena/geo_user_collection/" )


users = ['iKhoiBui']

users.each do |handle|

	tweets = contextual_stream.get_full_stream(handle)
	puts "Total tweets: #{tweets.length}"

	File.open(write_directory+handle+'.csv', "w") do |file|  
		tweets.each do |tweet|
			file.write "#{tweet.date}, #{tweet.text}"
		end
	}

end

