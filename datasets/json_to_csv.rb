_start =  Time.new(2012,10,22)
_end   =  Time.new(2012,11,07)

require 'csv'
require 'json'

#We're running on the server!  here we go!
require_relative '../server_config'
require_relative '../cloud_export/full_contextual_stream'
#Because it's meant to be run on the server

contextual_stream = FullContextualStreamRetriever.new(
	start_date:  _start,
	end_date:    _end,
	root_path:   "/home/kena/geo_user_collection/" )


coding_categories = ["Sentiment", "Reporting", "Movement","Actions","Information","Miscellaneous","Preparation","Other"]
default_columns = ['handle', 'id', 'date', 'text', 'geo']


#Processing

all_tweets = []

JSON.parse(File.read('./dataset1.json')).each do |id, tweet|
	all_tweets << tweet
end

tweets_by_user = {}
tweet_ids = []

JSON.parse(File.read('./dataset0.json')).first(5).each do |id, tweet|
	user = tweet["user"].scan(/sandy_nj_\d+_(.*)/)[0][0]
	tweet["user"] = user
	tweets_by_user[user] ||= contextual_stream.get_full_stream(user)

	found_tweet = tweets_by_user[user].collect{|tweet| tweet[:Id] == id}[0]

	tweet["date"] = found_tweet[:Date]
	coords = found_tweet[:Coordinates]
	puts coords
	if coords == '----'
		tweet["geo_coords"] = []
	else
		tweet["geo_coords"] = coords

	puts tweet
end



	

	# begin
	# 	from_twitter = client.status.show? :id=>tweet["id"]
	# 	# tweet["date"] =  from_twitter.created_at
	# 	puts tweet
	# rescue => e
	# 	puts e
	# 	puts "Nope, error on tweet http://twitter.com/#{tweet["user"]}/statuses/#{id}"
	# 	# tweet["geo_coords"] = 
	# end
	
	# puts tweet
end


# puts all_tweets.first

# y.each do |id, tweet|
# 	puts id
# end







# tweet = client.statuses.show? :id => 262249120994037760

# puts tweet.created_at
# puts tweet.user.screen_name


# CSV.open('all_output.csv', 'wb') do |csv|
# 	csv << default_columns+coding_categories
	
# 	all_tweets.each do |tweet|
# 		date = tweet[1]["date"]
# 		annotations = {}
# 		tweet[1]["annotations"].each do |ann|
# 			unless ann == "None"
# 				annotations[ann.split('-')[0]]=ann.split('-')[1]
# 			end
# 		end
# 		row = [date]
# 		columns.each do |column|
# 			if annotations[column].nil?
# 				row << ''
# 			else
# 				row << annotations[column]
# 			end
# 		end
# 		csv << row
# 	end
# end
