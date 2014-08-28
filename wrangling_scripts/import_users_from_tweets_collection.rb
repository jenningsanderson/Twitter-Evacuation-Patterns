#
# Connects to the current sandygeo.geo_tweets collection and then creates the
# twitterers collection based on the users from these tweets.
#
# Note: It will only import users if they had at least 3 tweets between Oct 20 - Nov 7
# The "3" is quite arbitrary, but with any less than that, the process will throw them out
# anyways.
#
# It will cap the user at 1300 Tweets, taking an even number off the beginning and the front.
# More than 1300 tweets results in a stack overflow.
#
#

require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/deprecation'
require 'mongo_mapper'

require 'mongo_mapper'

require_relative '../models/twitterer'
require_relative '../models/tweet'

#Static Setup
MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

conn = Mongo::MongoClient.new#('epic-analytics.cs.colorado.edu')
db = conn['sandygeo']
coll = db['geo_tweets']

limit = 10000000 #Hopefully an arbitrarily high limit

puts "Running the User Import for max (#{limit} )users"

existing_ids = Twitterer.distinct("id_str")

puts "There are #{existing_ids.length} distinct users in the collection already"

distinct_users = coll.distinct("user.id_str")

puts "There are #{distinct_users.length} in the entire geo_tweet collection"

to_import = (distinct_users - existing_ids).sort

puts "There are #{to_import.length} user ids left to import"

puts "Iterating over the cursor and building defined people (Twitterer) objects"

before_sandy = Time.new(2012,10,28)
after_sandy  = Time.new(2012,11,03)

import_count = 0
failed_count = 0

users_above_limit = 0

to_import.each_with_index do |uid, index|
	begin
		obj_tweets = []
		valid_count = 0
		user_tweets = coll.find(
			selector = {"user.id_str" => uid}, 
			opts	 = {:sort=> :asc}
		)

		if user_tweets.count > 1200
			puts user_tweets.first["user.screen_name"]
			users_above_limit += 1
			over = (((user_tweets.count)/ 1.5)).round
			user_tweets.skip( over )
		end

		user_tweets.each_with_index do |tweet, index|
			if index < 1200
				this_tweet = Tweet.new( tweet )
				if (this_tweet.date > before_sandy) and (this_tweet.date < after_sandy)
					valid_count +=1
				end
				obj_tweets << this_tweet
			else
				break
			end
		end

		unless valid_count < 3
			this_user = Twitterer.create( {:id_str => uid} )
			this_user.tweets = obj_tweets.sort_by{|tweet| tweet.date}
			this_user.issue = 120
			this_user.save
			import_count+=1
		else
			failed_count +=1
		end

		if (index%10).zero?
	    	print "..(#{import_count}/#{index+1})"
		end
	rescue
		puts "error"
		puts $!
	end
end

puts "\n-----------\n"

puts "Failed to meet criteria count: #{failed_count}"
puts "Had over 1200 tweets: #{users_above_limit}"
puts "Imported: #{import_count}"
