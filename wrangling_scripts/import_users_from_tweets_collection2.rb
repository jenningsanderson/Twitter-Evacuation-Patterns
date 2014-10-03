#
# User Import Script
#
# 1. Connects to current sandygeo.geo_tweets collection (Via MongoClient)
# 2. Connects to / Creates a Twitterers collection (via Mongoid)
# 3. Creates Twitterer objects from geo_tweets collection
#

require 'mongo'

require_relative '../models/twitterer'

#Setup Mongo Mapper
MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

#Hard-Coded connection to existing Collection
conn = Mongo::MongoClient.new('epic-analytics.cs.colorado.edu')
db = conn['sandygeo']
coll = db['geo_tweets']

limit = 10000000 #Hopefully an arbitrarily high limit

limit = 10

puts "Running the User Import for max (#{limit}) users"
existing_ids = Twitterer.distinct("id_str")
puts "There are #{existing_ids.length} distinct users in the collection already"

# distinct_users = coll.distinct("user.id_str", {:limit=>10})
# puts "There are #{distinct_users.length} in the entire geo_tweet collection"

distinct_users = ["102713979","103331100", "103510248", "103660472", "103961541", "104007389", "256002542", "38795633", "909635874", "100097597", "101769579", "101885261", "101932360", "101943648", "101946697", "101966401", "102247260", "102255847", "102521412",  "102689853"]

to_import = (distinct_users - existing_ids).sort.first(limit)
puts "There are #{to_import.length} user ids left to import"

puts "Iterating over the cursor and building defined people (Twitterer) objects"

before_sandy = Time.new(2012,10,28)
after_sandy  = Time.new(2012,11,03)

import_count = 0
failed_count = 0

users_above_limit = 0

trouble_users = []

to_import.each_with_index do |uid, index|
	begin
		obj_tweets = []
		valid_count = 0
		user_tweets = coll.find(
			selector = {"user.id_str" => uid}, 
			opts	 = {:sort=> {'created_at' => :asc} }
		)

		if user_tweets.count > 1200
			puts "Trouble User: #{uid}"
			trouble_users << uid
			users_above_limit += 1
			over = (((user_tweets.count)/ 1.1)).round
			user_tweets.skip( over )
		end

		# user_tweets.each_with_index do |this_tweet, index|
		# 	if index < 1200
		# 		if (this_tweet["created_at"] > before_sandy) and (this_tweet["created_at"] < after_sandy)
		# 			valid_count +=1
		# 		end
		# 		obj_tweets << Tweet.new(this_tweet)
		# 	else
		# 		break
		# 	end
		# end

		# print obj_tweets[0].inspect

		# unless valid_count < 3
			user = {:id_str=>uid}
			TwittererBase.create(id_str: uid)

			# this_user.tweets = obj_tweets.sort_by{|tweet| tweet.date}
			# this_user.issue = 120
			#this_user.save
			# import_count+=1
		# else
			# failed_count +=1
		# end

		if (index%10).zero?
	    	print "..(#{import_count}/#{index+1})"
		end
	rescue => e
		puts $!
		puts e.backtrace
		exit
	end
end

puts "\n-----------\n"

puts "Failed to meet criteria count: #{failed_count}"
puts "Had over 1200 tweets: #{users_above_limit}"
puts "Imported: #{import_count}"

print trouble_users
