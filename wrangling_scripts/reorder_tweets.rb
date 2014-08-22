#
# Reorder the Tweets to be temporally accurate

require 'mongo_mapper'

require_relative '../models/twitterer'
require_relative '../models/tweet'

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

Twitterer.where(
				
				:issue => 80 #Users that have already been processed
                
                ).limit(nil).each_with_index do |user, index|

	ordered_tweets = user.tweets.sort_by{|tweet| tweet.date}

	user.tweets = ordered_tweets

	#puts user.tweets.collect{|tweet| tweet.date}

	user.issue = 50

	user.save

	if (index % 10).zero?
		print "."
	elsif (index%101).zero?
		print "#{index}"
	end
end
