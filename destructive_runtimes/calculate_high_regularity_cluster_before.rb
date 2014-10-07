#
# High Regularity Location Calculations
#
# Only calculates for those locations BEFORE the storm hit


require_relative '../config.rb'

include TimeProcessing

if __FILE__ == $0

	
	results = Twitterer.find_each(:flag.ne => "tweet regularity before run 3")

	count = results.count
	puts "Found #{count} results" 

	results.each_with_index do |user, index|
		begin
			c_val 			= 0.0;
			base_cluster 	= nil

			user.clusters.each do |cluster_id, tweets|
				
				pert_tweets = tweets.select{ |tweet| tweet.date < Date.new(2012,10,29)}

				this_cluster_score = tweet_regularity(pert_tweets)

				if this_cluster_score > c_val
					c_val = this_cluster_score
					base_cluster = cluster_id.to_s
				end
			end

			unless base_cluster.nil?
				user.base_cluster = base_cluster
				user.base_cluster_score = c_val
			else
				user.unclassifiable = true
			end
			user.flag = "tweet regularity before run 3"
		rescue => e
			puts "Error!"
			puts e.backtrace
			user.flag = "tweet regularity calc error"
		end
		
		user.save

		if (index%100).zero?
			puts "-------Processed #{index} / #{count}------------"
		end
	end
end