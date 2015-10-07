autoload :TimeProcessing, 'modules/time_processing'
autoload :UserBehavior, 'modules/user_behavior'

require_relative 'tweet'

#=Twitterer Active During Hurricane Sandy
#
#Inheriting basic Twitter User behavior and attributes from TwittererBase, this
#
class Twitterer

	include Mongoid::Document
	embeds_many :tweets

	#Define User fields
	field :id_str,          				type: String
	field :handle,          				type: String
	field :account_created, 				type: Time

	# field :issue, 								type: Integer #A flag for keeping track of processing -- in Mongo
	field :flag,      							type: Integer, default: -1

	field :cluster_locations, 			type: Hash, default: {}
	field :unclustered_percentage,	type: Integer, default: -1

	field :unclassifiable,          type: Boolean, default: true
	field :rel_movement,            type: Array

	field :evacuated,								type: String, default: nil
	field :secondary,							  type: String, default: nil

	field :tweet_count,							type: Integer, default: -1

	field :one_month_prior_clusters, type: Array, default []

	# field :base_cluster,						type: String
	# field :base_cluster_score,			type: Float
	# field :base_cluster_location,   type: Array

	# field :base_cluster_risk,				type: Integer

	#Get Geo functions for geotwitterer
	include EpicGeo::GeoTwitterer

	#Need geoprocessing functionality as well
	include EpicGeo::GeoProcessing

	include TimeProcessing
	include UserBehavior

	# include UserBehavior::ShelterInPlace

	#Enable access to points of interest
	attr_reader :sip_conf, :evac_conf

	#Mostly for testing, but maybe need access to these
	attr_reader :unclassified_tweets

	#Get all of a user's contextual stream tweets
	def contextual_stream
		tweets.select{|t| t.contextual }
	end

	#Get all of a user's keyword tweets only
	def keyword_tweets
		tweets.select{|t| !t.contextual}
	end

	#Add a tweet object to this Twitterer's tweets collection
	def add_tweet(tweet)
		tweets << tweet
	end

	#Set & return a user's tweets to be sorted by the Tweet#created_at function
	def sort_tweets_by_date
		tweets = @tweets.sort_by{|tweet| tweet.created_at}
	end

	#Helper functions
	def clusters
		tweet_clusters = tweets.group_by{ |tweet| tweet.cluster_id }
		tweet_clusters.delete('-1')
		return tweet_clusters
	end

	def during_storm_clusters
		ds_clusters = clusters
		clusters.each do |id, tweets|
			no_tweets = true
			tweets.each do |t|
				if t.date > $times[:one_week_before] and t.date < $times[:one_week_after]
					no_tweets = false
					break
				end
			end
			ds_clusters.delete(id) if no_tweets
		end
		return ds_clusters
	end

	def base_cluster_point
		p = cluster_locations[base_cluster.to_s]
		unless p.nil?
			return $factory.point(p[0],p[1])
		else
			return nil
		end
	end

	def cluster_as_point(cluster)
		p = cluster_locations[cluster.to_s]
		unless p.nil?
			return $factory.point(p[0],p[1])
		else
			return nil
		end
	end

	def time_bounded_tweets(time_start, time_end)
		return tweets.select{|t| t.date > time_start and t.date < time_end}
	end

	#
	#
	# Returns:
	# => nil if there is no activity between those times.
	def get_highest_scoring_location_between_two_dates(start_date, end_date)
		cluster_scores = []
		relevant_tweets = time_bounded_tweets(start_date, end_date)

		relevant_clusters = relevant_tweets.group_by{|t| t.cluster_id}

		unclustered = relevant_clusters.delete("-1")

		#If there are no clusters during this time, then we need to look at the unclustered
		if relevant_clusters.count.zero?
			if unclustered.count.zero?
				return nil
			else
				unclustered
			end

			relevant_clusters.each do |k,v|
				cluster_scores << {id: k, score: tweet_regularity(v)}
			end

			base_cluster = cluster_scores.sort_by{|c| c[:score]}.last

			if base_cluster.nil? or base_cluster[:id].nil?
				return nil
			else
				return base_cluster[:id]
			end
		end
	end

	def week_one_tweets
		return tweets.select{|t| t.date > TIMES[:event] and t.date < TIMES[:one_week]}
	end

	def two_days_tweets
		return tweets.select{|t| t.date > TIMES[:event] and t.date < TIMES[:two_days]}
	end

	def tweets_in_time_range(start_time, end_time)
		return tweets.select{|t| t.date > start_time and t.date < end_time}
	end

	def week_one_linestring
		points = []
		week_one_tweets.each do |t|
			unless t.cluster < 0
				points << cluster_as_point(t.cluster)
			end
		end
		$factory.line_string(points)
	end

	def get_base_cluster
		prev_val = 0
		c = nil
		clusters.each do |cluster_id, tweets|
			new_val = tweet_regularity(tweets.reject{ |t| t["date"] > TIMES[:event] })
			# puts "#{cluster_id}: #{new_val}"
			if new_val > prev_val
				prev_val = new_val
				c = cluster_id
			end
		end
		return c
	end


		# =Get Clusters from the User's Tweet Loctions
		#
		#
		#

		# def prev_clustering_stuff
		#
		# 	#Calculate T_scores
		# 	t_scores = {} #t_scores by cluster
		# 	#Sort the clusters by length (number of tweets is most important, as that's our indicator)
		# 	@clusters.sort_by{|k,v| v.length}.reverse.each do |id, cluster|
		# 		#The t_score is the spread, weighted by tweets.
		# 		t_scores[id] = score_temporal_patterns(cluster)
		# 		#puts "Cluster: #{id} has #{cluster.length} tweets with T_Score of #{t_scores[id]}"
		# 	end
		# 	@t_scores = t_scores #Save the t_scores for later access...
		#
		# 	#Now save clusters_by_day for later access...
		# 	@clusters_per_day = sort_clusters_by_day(@clusters)
		# end
		#
		#
		# #The new movement analysis -- will make calls to the time_processing script.
		# def movement_analysis
		#
		# 	#There are now two scores, the winner takes all.
		# 	@sip_conf  = 0
		# 	@evac_conf = 0
		#
		# 	#Check that the user has locations...
		# 	clusters = clusters_per_day
		# 	pertinent_clusters = clusters_per_day.reject{|k,v| k.to_i > 314 or k.to_i < 300}
		#
		# 	if pertinent_clusters.keys.length < 3 #Need at least 3 known clusters to classify
		# 		@unclassifiable = true
		# 		return
		# 	end
		#
		# 	if pertinent_clusters.values.flatten.uniq.count == 1
		# 		@shelter_in_place = true
		# 		@shelter_location = @cluster_locations[pertinent_clusters.values.flatten[0]]
		#
		# 		#Incrememnt @sip based on how many points we have.
		# 		@sip_conf += 50 + (50 * (pertinent_clusters.keys.length/14.to_f) )
		# 		return
		# 	end
		#
		# 	#There was more than one cluster involved, so there is some level of movement.
		# 	before, during, after = score_cluster_pattern( pertinent_clusters, @t_scores, before_home_cluster )
		#
		# 	if during.empty?
		# 		#Need to know where they were DURING the event
		# 		@unclassifiable = true
		# 		return
		# 	end
		#
		# 	during_cluster = mode(during)
		# 	@shelter_location = cluster_locations[during_cluster]
		#
		# 	before_cluster = mode(before) || before_home_cluster || nil
		#
		# 	unless after.empty?
		# 		after_cluster  = mode(after.flatten)
		# 	end
		#
		# 	if before_cluster == before_home_cluster
		# 		@sip_conf 	+= 20 #They get confidence boost for their known home to be their before storm home
		# 		@evac_conf 	+= 20
		#
		# 	else #If they're not the same, check that they're not super close to eachother... the clustering may be off.
		# 		p1 = GEOFACTORY.point(cluster_locations[before_cluster][0],cluster_locations[before_cluster][1])
		# 		p2 = GEOFACTORY.point(cluster_locations[before_home_cluster][0],cluster_locations[before_home_cluster][1])
		#
		# 		if ( ( p1.distance p2 ) < 100 )#If the two are less than 100 meters apart, then they should be the same cluster
		# 			if (during_cluster == before_cluster) or (during_cluster == before_home_cluster)
		# 				@sip_conf += 50
		# 			else
		# 				@evac_conf += 50
		# 			end
		# 		end
		# 	end
		#
		# 	if during_cluster == before_cluster
		# 		@sip_conf	+= 50
		# 		unless after_cluster.nil?
		# 			if after_cluster == during_cluster
		# 				@sip_conf += 30
		# 			end
		# 		end
		# 	elsif during_cluster == before_home_cluster
		# 		@sip_conf += 40
		#
		# 		#Welcome to evacuation territory...
		# 	else
		# 		@evac_conf += 30
		# 		if during.uniq.count == 1
		# 			@evac_conf += 40 #They only went one place
		# 		elsif during.include? before_cluster or during.include? before_home_cluster
		# 			@sip_conf += 10
		# 		end
		# 	end
		#
		# 	return 0
		#
		# end



		#------------------------ Deprecated POI Functions -------------------------#

		#Find the median point of the densest cluster from a set of clusters
		# => This function calls functions from geoprocessing
		# => The incoming tweet_clusters is a hash from DBscan
		# def get_weighted_poi_from_clusters(tweet_clusters)
		#
		# 	#A metric for confidence
		# 	@tri_confidence = 0 # => unimplemented
		#
		# 	#This function DOES account for time it's called in the get_most_dense_cluster function
		#
		# 	#Be careful here because tweet_clusters is a Hash where one key may be negative 1.
		# 	# Remove the key of -1 if it exists (This is the group of scattered tweets)
		# 	if tweet_clusters.keys.include? -1
		# 		tweet_clusters.delete(-1)
		# 	end
		#
		# 	unless
		# 		tweet_clusters.length.zero?
		#
		# 		#Find the densest cluster
		# 		densest_cluster = get_most_dense_cluster(tweet_clusters.values) #Pass in just the points
		#
		# 		#Find the median point
		# 		return find_median_point(densest_cluster.collect{|tweet| tweet["coordinates"]["coordinates"]})
		#
		# 		# => returns [x,y] (Not a point object)
		# 	else
		# 		return [nil, nil]
		# 	end
		# end

		# ----------------- Evacuation Analysis Functions (deprecated)-----------------#

		#The type is either 'before, during, or after'
		#coords is an array (lon, lat) to be saved...
		# def set_poi(type, coords)
		# 	unless coords[0].nil?
		# 		instance_eval "@#{type} = #{coords}"
		# 	end
		# end

		#The triangle analysis method
		# def build_evac_triangle
		# 	unless @before.nil? or @during.nil? or @after.nil?
		# 		before = @@tweet_factory.point(@before[0], @before[1])
		# 		during = @@tweet_factory.point(@during[0], @during[1])
		# 		after  = @@tweet_factory.point(@after[0],  @after[1])
		# 		triangle_points = [ before, during, after, before]
		#
		# 		evac_ring = @@tweet_factory.linear_ring(triangle_points)
		# 		evac_triangle = @@tweet_factory.polygon(evac_ring)
		#
		# 		@triangle_area = evac_triangle.area
		# 		@triangle_perimeter = evac_ring.length
		#
		# 		@before_during = before.distance(during)
		# 		@during_after  = during.distance(after)
		# 		@before_after  = before.distance(after)
		#
		# 		@isoceles_ratio = (@before_during / @during_after)
		# 	end
		# end

		# Split the tweets by dates in an array of dates
		# def split_tweets_into_time_bins(time_bins)
		# 	binned_tweets = []
		#
		# 	(0..time_bins.length-2).each do |index|
		# 		binned_tweets << tweets.select do |tweet|
		# 			tweet["date"] > time_bins[index] and tweet["date"] < time_bins[index+1]
		# 		end
		# 	end
		#
		# 	return binned_tweets
		# end
	end #End of Twitterer Class
