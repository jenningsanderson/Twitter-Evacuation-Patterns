#
# Reorder the Tweets to be temporally accurate
require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/deprecation'
require 'mongo_mapper'

require_relative '../models/twitterer'
require_relative '../models/tweet'

#Static Setup
MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

sort_count = 0

Twitterer.where(
				:tweet_count.gte => 1 #All users
                
                ).limit(nil).sort(:tweet_count).each_with_index do |user, index|

	tweet_dates = user.tweets.collect{|tweet| tweet.date}

	unless (tweet_dates == tweet_dates.sort)

		ordered_tweets = user.tweets.sort_by{|tweet| tweet.date}

		user.tweets = ordered_tweets

		user.issue = 50

		user.save

		sort_count +=1
	end

	if (index % 10).zero?
		print "."
	elsif (index%101).zero?
		print "(#{sort_count} / #{index})"
	end
end
