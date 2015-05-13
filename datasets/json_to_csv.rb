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

JSON.parse(File.read('./dataset0.json')).each do |id, tweet|
	user = tweet["user"].scan(/sandy_nj_\d+_(.*)/)[0][0]
	tweet["user"] = user
	tweets_by_user[user] ||= contextual_stream.get_full_stream(user)

	found_tweet = tweets_by_user[user].select{|tweet| tweet[:Id] == id}.first

	if found_tweet.nil?
		puts "ERROR!: #{id}"
	else
		tweet["date"] = found_tweet[:Date]
		coords = found_tweet[:Coordinates]
		if coords == "------"
			tweet["geo_coords"] = []
		else
			tweet["geo_coords"] = coords
		end
		all_tweets << tweet
	end
end

grouped = all_tweets.group_by{ |tweet| tweet["user"] }

CSV.open('all_output.csv', 'wb') do |csv|
	csv << default_columns+coding_categories
	
	grouped.each do |user, tweets|
		CSV.open('individual_users/'+user+'.csv', 'wb') do |indiv_csv|
			indiv_csv << default_columns+coding_categories
			tweets.sort_by{|tweet| tweet["date"] }.each do |tweet|
				annotations = {}
				tweet["annotations"].each do |ann|
					unless ann == "None"
						annotations[ann.split('-')[0]]=ann.split('-')[1:].join(',')
					end
				end
				row = [tweet["user"], tweet["id"], tweet["date"], tweet["text"], tweet["geo_coords"]]
				
				coding_categories.each do |column|
					if annotations[column].nil?
						row << ''
					else
						row << annotations[column]
					end
				end
				csv << row
				indiv_csv << row
			end
		end
	end
end
