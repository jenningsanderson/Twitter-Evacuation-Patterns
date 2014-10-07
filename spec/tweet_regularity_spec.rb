require 'spec_helper'

include TimeProcessing

describe TimeProcessing do

	before :all do 
		MongoMapper.connection = Mongo::Connection.new# (Local)
		MongoMapper.database = 'sandygeo'
	end

	it "Can determine the Twitterer's regularity" do
		user = Twitterer.first

		user.clusters.each do |id, tweets|
			puts "#{id} - #{tweets.length} - #{tweet_regularity(tweets)/user.tweet_count}"
		end
	end
end