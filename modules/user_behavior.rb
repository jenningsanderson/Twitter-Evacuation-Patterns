#= The main Module for movmenet derivation
#
#
#
module UserBehavior

	#= Using DBScan, put all their tweets into clusters!
	#
	def process_tweets_to_clusters

		#Create a new instance of the DBScanner, set the parameters.
		#Passes an array of Tweet Objects, which have their own distance function
		dbscanner = EpicGeo::Clustering::DBScan.new(tweets, epsilon=50, min_pts=2) #This seems to work okay...

		# Run the db_scan algorithm
		clusters = dbscanner.run

		clusters.each do |cluster_id, tweets|
			tweets.each do |tweet|
				tweet.cluster_id = cluster_id.to_s
				tweet.save!
			end
		end

		#Save the cluster locations (simple lon/lat arrays)
		self.cluster_locations = {}

		#Go through the clusters and find the median locations
		clusters.keys.each do |key|
			key_string = key.to_s

			#Set the cluster locations as well (for storage, we can plot tweets on these later...)!
			unless key_string=="-1"
				self.cluster_locations[key_string] ||= find_median_point(clusters[key].collect{|tweet| tweet.coordinates})
			end
		end

		#Throw away the unclassifiable cluster (Save them as a variable with the Twitterer for now)
		unclassified_tweets = clusters.delete(-1)
		self.unclustered_percentage = (unclassified_tweets.length.to_f / tweets.count*100).round

		if clusters.empty?
			self.unclassifiable = true
		else
			self.unclassifiable = false
		end
	end

	def before_storm_home_location
		nil
	end

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
