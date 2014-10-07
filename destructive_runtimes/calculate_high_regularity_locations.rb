#
# High Regularity Location Calculations
#
# => This runtime goes through the Twitterers collection and clusters a user's tweets.
# => Importantly, it embeds the cluster into the tweet on save.
#
require_relative '../config.rb'

include TimeProcessing

if __FILE__ == $0

	
	results = Twitterer.where(:tweet_count.gt => 1000, :flag.ne => "tweet regularity run 1")

	count = results.count
	puts "Found #{count} results" 

	results.each_with_index do |user, index|
		begin
			c_val 			= 0.0;
			base_cluster 	= nil

			user.clusters.each do |cluster_id, tweets|
				this_cluster_score = tweet_regularity(tweets)
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
			user.flag = "tweet regularity run 1"
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