module UserBehavior

	def during_storm_cluster(args={})
		start_date 	= args[:start_date] || TIMES[:event]
		end_date   	= args[:end_date]   || TIMES[:two_days]
		
		#Now use the same logic as calculating the base cluster
		c_val 			= 0.0;
		storm_cluster 	= nil
		clusters.each do |cluster_id, tweets|
			pert_tweets = tweets.select{ |tweet| tweet.date > start_date and tweet.date < end_date}
			this_cluster_score = tweet_regularity(pert_tweets)
			if this_cluster_score > c_val
				c_val = this_cluster_score
				storm_cluster = cluster_id.to_s
			end
		end
		return storm_cluster
	end

	#Get a user's tweets from a specific time range
	def during_storm_tweets(args ={})
		start_date 	= args[:start_date] || TIMES[:event]
		end_date   	= args[:end_date]   || TIMES[:two_days]
		
		tweets.select{ |tweet| tweet.date > start_date and tweet.date < end_date}
	end

	#Functions relevant to evacuation behavior
	#
	#TODO: Make this less crude
	module Evacuator
		def evacuated?
			during_storm_p = cluster_as_point(during_storm_cluster)
			unless during_storm_p.nil? or base_cluster_point.nil?
				return during_storm_p.distance(base_cluster_point) > 500
			else
				return nil
			end
		end
	end


	#Functions relevant to users who sheltered in place
	#
	#TODO: Make this less crude
	module ShelterInPlace
		def sheltered_in_place?
			during_storm_p = cluster_as_point(during_storm_cluster)
			unless during_storm_p.nil? or base_cluster_point.nil?
				return during_storm_p.distance(base_cluster_point) < 500
			else
				return nil
			end
		end
	end

end