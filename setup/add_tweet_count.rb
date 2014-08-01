#
# Add the tweet count for before, during, after to each user for easier filtering
#

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

#Define the timewindows to split the tweets into
sandy_dates = [
  Time.new(2012,10,20), #Start of dataset
  Time.new(2012,10,28), #Start of storm
  Time.new(2012,11,1),  #End of Storm
  Time.new(2012,11,9)   #End of Dataset
]

#These names correspond with the KML styles for coloring
time_frames = ["before", "during", "after"]

#Search the Twitterer collection
Twitterer.where( :before_tweet_count => nil).limit(nil).each_with_index do |user, index|

	binned_tweets = user.split_tweets_into_time_bins(sandy_dates)

	user.before_tweet_count = binned_tweets[0].length
	user.during_tweet_count = binned_tweets[1].length
	user.after_tweet_count = binned_tweets[2].length

	user.save

	if (index%100).zero?
  		puts "\n\n\n---------------------#{index}--------------------------------\n\n\n"
  	end

end