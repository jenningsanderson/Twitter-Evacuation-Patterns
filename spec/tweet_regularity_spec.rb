require 'spec_helper'

include TimeProcessing

describe TimeProcessing do

	before :all do 
		MongoMapper.connection = Mongo::Connection.new# (Local)
		MongoMapper.database = 'sandygeo'
	end

	it "Can determine the Twitterer's regularity" do
		user = Twitterer.where(:handle=> "mattgunn").first

		user.clusters.each do |id, tweets|

			#Check it with tweets just from before the event...
			pert_tweets = tweets.select{ |tweet| tweet.date < Date.new(2012,10,29)}
			
			puts "#{id} - #{tweets.length} - #{tweet_regularity(tweets)}"

			puts "#{id} - #{pert_tweets.length} - #{tweet_regularity(pert_tweets)}"

		end
	end
end