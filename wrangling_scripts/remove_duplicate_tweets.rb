#
# Unfortunately there are perhaps duplicate tweets...  Let's take a look
#
# So when the contextual streams were imported, I was left with duplicate tweets...
# This script will go through and update those.
#


require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

#Search the Twitterer collection
Twitterer.where( :affected_level => 1).each_with_index do |user, index|
  
  first_tweet = user.tweets.first
  
  prev_tweet = user.tweets.first

  user.tweets.each do |this_tweet|
  	
  	unless this_tweet == first_tweet
	
	  	if this_tweet.date == prev_tweet.date
	  		if this_tweet.text == prev_tweet.text
	  			puts this_tweet.text
	  			#puts prev_tweet.inspect
	  			user.tweets.delete(this_tweet)
	  			user.save
	  		end
	  	end
	end
	prev_tweet = this_tweet
  end


  if (index%100).zero?
  	puts "\n\n\n---------------------#{index}--------------------------------\n\n\n"
  end
end