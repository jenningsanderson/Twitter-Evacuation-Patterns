# Twitterer Model
#
# This model describes a single user of Twitter.  It is currently
# setup for a user of the Hurricane Sandy dataset for evacuation analysis
#
# This class extends a MongoMapper document with embedded Tweet objects
#
# For the purpose of Efficiency, this model only includes tweets with Geotags.
#
#

require 'mongo_mapper'
require 'active_model'
require 'rgeo' 					# RGEO is stronger geo-processing
require 'georuby'				# Georuby allows for easier point => KML

#Load the geoprocessing algorithms
require_relative '../processing/geoprocessing' #Is this actually necessary?

class Twitterer

	#An RGeo Factory that is geospatially aware for all calculations
	@@tweet_factory = RGeo::Geographic.simple_mercator_factory

	#Enable access to points of interest
	attr_reader :points, :sip_conf, :evac_conf

	#Mostly for testing, but maybe need access to these
	attr_reader :clusters, :unclassified_tweets


	#Extend MongoMapper
	include MongoMapper::Document

	#Key Twitterer Values needed
	key :id_str, 			String, :required => true, :unique => true
	key :handle, 			String
	key :tweet_count, 		Integer
	key :issue,				Integer #A flag for keeping track of processing

	#Embed the following types of documents:
	many :tweets

	key :during_storm_movement, Array 	#This will be made into a LineString
	key :cluster_locations, 	Hash	#This has :before_home and :after_home
	key :cluster_movement_pattern, Array

	key :hazard_level_before, Integer
	key :unclassifiable,    Boolean
	key :shelter_in_place,  Boolean
	key :shelter_location, 	Array
	key :confidence, 		Float

	key :sip_conf, 			Float
	key :evac_conf,			Float


	#Cluster Info
	key :clusters_per_day,	Hash
	key :t_scores,			Hash

	key :before_home_cluster, String
	key :after_home_cluster, String

	key :unclassified_percentage,	Integer

	key :path_affected,				Boolean

	#On Save functions
	before_save do
		self.tweet_count = tweets.count #Update the local tweet_count variable.
	end



# --------------------- GeoSpatial General Functions ------------------------#

	#Create an rgeo points array for all of a user's tweets
	def process_tweet_points
		@points = tweets.collect{ |tweet| tweet.point } #tweet.point returns an Rgeo point for the tweet
	end

	# Return Just the points as a multi_point geo object
	def user_points
		if @points.nil?
			process_tweet_points
		end
		@@tweet_factory.multi_point(@points)
	end

	#Create LineString of points
	def user_path
		if @points.nil?
			process_tweet_points
		end
		@userpath = @@tweet_factory.line_string(@points)
	end


# ----------------- New POI Algorithm Functions -------------------#
	def get_and_store_clusters
		dbscanner = DBScanCluster.new(tweets, epsilon=25, min_pts=2) #This seems to work okay...

		# Run the db_scan algorithm
	    clusters = dbscanner.run
	    @clusters = {}
	    @cluster_locations ||= {}

	    #Set the instance clusters variable.  Note the keys are strings, not integers
	    clusters.keys.each do |key|
	    	key_string = key.to_s
	    	@clusters[key_string] = clusters[key]
	    	
	    	#Set the cluster locations as well (for storage, we can plot tweets on these later...)!
	    	unless key_string=="-1"
	    		@cluster_locations[key_string] ||= find_median_point(@clusters[key_string].collect{|tweet| tweet["coordinates"]["coordinates"]})
	    	end
	    end
	   
	    #Throw away the unclassifiable cluster (Save them as a variable with the Twitterer for now)
		@unclassified_tweets = @clusters.delete("-1")
		@unclassified_percentage = (@unclassified_tweets.length.to_f / tweets.count*100).round

		if @clusters.empty?
			@unclassifiable = true

		else #Continue with the calculations because the user DOES have clusters

			#Calculate T_scores
			t_scores = {} #t_scores by cluster
			#Sort the clusters by length (number of tweets is most important, as that's our indicator)
			@clusters.sort_by{|k,v| v.length}.reverse.each do |id, cluster|
				#The t_score is the spread, weighted by tweets.
				t_scores[id] = score_temporal_patterns(cluster)
				#puts "Cluster: #{id} has #{cluster.length} tweets with T_Score of #{t_scores[id]}"
			end
			@t_scores = t_scores #Save the t_scores for later access...

			#Now save clusters_by_day for later access...
			@clusters_per_day = sort_clusters_by_day(@clusters)
		end
	end

	#The new movement analysis -- will make calls to the time_processing script.
	def movement_analysis

		#There are now two scores, the winner takes all.
		@sip_conf  = 0
		@evac_conf = 0

		#Check that the user has locations...
		clusters = clusters_per_day
		pertinent_clusters = clusters_per_day.reject{|k,v| k.to_i > 314 or k.to_i < 300}

		if pertinent_clusters.keys.length < 3 #Need at least 3 known clusters to classify
			@unclassifiable = true
			return
		end

		if pertinent_clusters.values.flatten.uniq.count == 1
			@shelter_in_place = true
			@shelter_location = @cluster_locations[pertinent_clusters.values.flatten[0]]
			
			#Incrememnt @sip based on how many points we have.
			@sip_conf += 50 + (50 * (pertinent_clusters.keys.length/14.to_f) )
			return
		end

		#There was more than one cluster involved, so there is some level of movement.
		before, during, after = score_cluster_pattern( pertinent_clusters, @t_scores, before_home_cluster )

		if during.empty?
			#Need to know where they were DURING the event
			@unclassifiable = true
			return
		end

		during_cluster = mode(during)
		@shelter_location = cluster_locations[during_cluster]

		before_cluster = mode(before) || before_home_cluster || nil

		unless after.empty?
			after_cluster  = mode(after.flatten)
		end

		if before_cluster == before_home_cluster
			@sip_conf 	+= 20 #They get confidence boost for their known home to be their before storm home
			@evac_conf 	+= 20
		
		else #If they're not the same, check that they're not super close to eachother... the clustering may be off.
			p1 = GEOFACTORY.point(cluster_locations[before_cluster][0],cluster_locations[before_cluster][1])
			p2 = GEOFACTORY.point(cluster_locations[before_home_cluster][0],cluster_locations[before_home_cluster][1])
			
			if ( ( p1.distance p2 ) < 100 )#If the two are less than 100 meters apart, then they should be the same cluster
				if (during_cluster == before_cluster) or (during_cluster == before_home_cluster)
					@sip_conf += 50
				else
					@evac_conf += 50
				end
			end
		end

		if during_cluster == before_cluster
			@sip_conf	+= 50
			unless after_cluster.nil?
				if after_cluster == during_cluster
					@sip_conf += 30
				end
			end
		elsif during_cluster == before_home_cluster
			@sip_conf += 40

			#Welcome to evacuation territory...
		else
			@evac_conf += 30
			if during.uniq.count == 1
				@evac_conf += 40 #They only went one place
			elsif during.include? before_cluster or during.include? before_home_cluster
				@sip_conf += 10
			end
		end

		return 0
			
	end



#------------------------ Deprecated POI Functions -------------------------#

	#Find the median point of the densest cluster from a set of clusters
	# => This function calls functions from geoprocessing
	# => The incoming tweet_clusters is a hash from DBscan
	def get_weighted_poi_from_clusters(tweet_clusters)

		#A metric for confidence
		@tri_confidence = 0 # => unimplemented

		#This function DOES account for time it's called in the get_most_dense_cluster function

		#Be careful here because tweet_clusters is a Hash where one key may be negative 1.
		# Remove the key of -1 if it exists (This is the group of scattered tweets)
		if tweet_clusters.keys.include? -1
			tweet_clusters.delete(-1)
		end

		unless
			tweet_clusters.length.zero?

			#Find the densest cluster
			densest_cluster = get_most_dense_cluster(tweet_clusters.values) #Pass in just the points

			#Find the median point
			return find_median_point(densest_cluster.collect{|tweet| tweet["coordinates"]["coordinates"]})

			# => returns [x,y] (Not a point object)
		else
			return [nil, nil]
		end
	end

# ----------------- Evacuation Analysis Functions (deprecated)-----------------#

	#The type is either 'before, during, or after'
	#coords is an array (lon, lat) to be saved...
	def set_poi(type, coords)
		unless coords[0].nil?
			instance_eval "@#{type} = #{coords}"
		end
	end

	#The triangle analysis method
	def build_evac_triangle
		unless @before.nil? or @during.nil? or @after.nil?
			before = @@tweet_factory.point(@before[0], @before[1])
			during = @@tweet_factory.point(@during[0], @during[1])
			after  = @@tweet_factory.point(@after[0],  @after[1])
			triangle_points = [ before, during, after, before]

			evac_ring = @@tweet_factory.linear_ring(triangle_points)
			evac_triangle = @@tweet_factory.polygon(evac_ring)

			@triangle_area = evac_triangle.area
			@triangle_perimeter = evac_ring.length

			@before_during = before.distance(during)
			@during_after  = during.distance(after)
			@before_after  = before.distance(after)

			@isoceles_ratio = (@before_during / @during_after)
		end
	end

	# Split the tweets by dates in an array of dates
	def split_tweets_into_time_bins(time_bins)
		binned_tweets = []

		(0..time_bins.length-2).each do |index|
			binned_tweets << tweets.select do |tweet|
				tweet["date"] > time_bins[index] and tweet["date"] < time_bins[index+1]
			end
		end

		return binned_tweets
	end






	# --------------------- GeoJSON Functions -------------------------#
	#Returns a geojson MultiPoint object with each tweet as a point
	def individual_points_json
		points = tweets.collect{ |tweet| tweet.coordinates["coordinates"]}
		return {:type => "MultiPoint", :coordinates => points}
	end


	#Return a geojson Feature Collection of Individual Tweets
	def individual_tweets_json
		features = []
		tweets.each do |tweet|
			features << {:type => "Feature",
									 :geometry=> tweet["coordinates"],
									 :properties => {
											:text => tweet["text"],
											:created_at => tweet["date"],
											:handle => tweet["handle"].join(',')
										}}
		end
		return {:type => "FeatureCollection", :features => features}
	end

	#Return a geojson linestring of a user's tweet locations
	def full_user_path_json
		points = tweets.collect{ |tweet| tweet.coordinates["coordinates"]}
		return {:type => "LineString", :coordinates => points}
	end

	def full_median_point_json
		median_point = find_median_point tweets.collect do |tweet|
			tweet.coordinates["coordinates"]
		end

		return {:type => "Point", :coordinates => median_point}
	end



	# --------------------- KML Functions -------------------------#

	def userpath_as_epic_kml
		linestring = GeoRuby::SimpleFeatures::LineString.from_coordinates(
			tweets.collect{|tweet| tweet.coordinates["coordinates"]} )

		{:name 			=> handle,
		 :geometry => linestring,
		}
	end

	# A helper function to convert a point to epic-KML
	def point_as_epic_kml(name, x, y, style=nil)
		{ :name => name,
			:style => style,
		  :geometry => GeoRuby::SimpleFeatures::Point.from_coordinates([x,y]) }
	end

end #End of Twitterer Class



#Deprecated Code: 
	# def new_location_calculation

	# 	@confidence = 0

	# # 1. Build clusters from tweets with DBScan.	

	# 	#Calls the DBScan Algorithm from ../processing/db_scan.rb
	# 	# Parameters: epsilon = max distance (25 meters), min_pts = 2, for triangulation
	# 	dbscanner = DBScanCluster.new(tweets, epsilon=25, min_pts=2) #This seems to work okay...

	# 	# Run the db_scan algorithm
	#     clusters = dbscanner.run
	#     @clusters = {}

	#     #Set the instance clusters variable.  Note the keys are strings, not integers
	#     clusters.keys.each do |key|
	#     	@clusters[key.to_s] = clusters[key]
	#     end

	#     #Throw away the unclassifiable cluster (Save them as a variable with the Twitterer for now)
	# 	@unclassified_tweets = @clusters.delete("-1")
	# 	@unclassified_percentage = (@unclassified_tweets.length.to_f / tweets.count*100).round


	# 	if @clusters.empty?
	# 		@unclassifiable = true

	# 	else #Continue with the analysis because the user DOES have clusters
	
	# # 2. Analyze the clusters to find temporal holes and identify before and after home locations

	# 		#Cluster locations will be saved to the user for later referencing
	# 		@cluster_locations = {:before_home=>[], :after_home=>[]}

	# 		t_scores = {} #t_scores by cluster

	# 		#Sort the clusters by length (number of tweets is most important, as that's our indicator)
	# 		@clusters.sort_by{|k,v| v.length}.reverse.each do |id, cluster|
				
	# 			#The t_score is the spread, weighted by tweets.
	# 			t_scores[id] = score_temporal_patterns(cluster)
				
	# 			puts "Cluster: #{id} has #{cluster.length} tweets with T_Score of #{t_scores[id]}"
	# 		end

	# 		@t_scores = t_scores #Save the t_scores for later access...

	# 		#Process before & after points
	# 		most_likely_home_cluster = find_best_before_cluster(@clusters, t_scores)
				
	# 		unless most_likely_home_cluster.nil?
	# 			puts "Before Home Location: #{most_likely_home_cluster}"

	# 			loc = find_median_point(@clusters[most_likely_home_cluster].collect{|tweet| tweet["coordinates"]["coordinates"]})
	# 			@cluster_locations[most_likely_home_cluster] = loc
	# 			@cluster_locations[:before_home] = loc
	# 		else
	# 			@cluster_locations[:before_home] = nil
	# 		end
		
	# 		most_likely_post_event_home = find_best_after_cluster(@clusters, t_scores)
	# 		unless most_likely_post_event_home.nil?
	# 			puts "After Home Location: #{most_likely_post_event_home}"
	# 			if @cluster_locations[most_likely_post_event_home].nil?
	# 				loc = find_median_point(@clusters[most_likely_post_event_home].collect{|tweet| tweet["coordinates"]["coordinates"]})
	# 				@cluster_locations[most_likely_post_event_home] = loc
	# 				@cluster_locations[:after_home] = loc
	# 			else
	# 				@cluster_locations[:after_home] = cluster_locations[most_likely_post_event_home]
	# 			end
	# 		else
	# 			@cluster_locations[:after_home] = nil
	# 		end
		
	# 	#The temporal pattern will return 0 or 1 if it's a short case, otherwise it will
	# 		points_of_interest = find_temporal_pattern(@clusters, t_scores)
	# 	end
	# # 		# puts "POI: #{points_of_interest}"

	# # 		# if points_of_interest.is_a? Integer
	# # 		# 	@unclassifiable = true
	# # 		# elsif points_of_interest.length==1
	# # 		# 	@shelter_in_place = true
	# # 		# 	@shelter_in_place_location = cluster_locations[points_of_interest[0]]
	# # 		# 	@confidence = 50
	# # 		# else

	# # 		# 	movement_path = [points_of_interest.shift]
	# # 		# 	mp_index = 0
	# # 		# 	#In this case, POIs is an array of cluster IDs.  We will build a linestring from it.
	# # 		# 	points_of_interest.each do |cluster_id|
					
	# # 		# 		unless movement_path[mp_index] == cluster_id
	# # 		# 			movement_path << cluster_id
	# # 		# 			mp_index +=1
	# # 		# 		end
	# # 		# 	end
				
	# # 		# 	puts "Movement Path: #{most_likely_home_cluster} :: #{movement_path} :: #{most_likely_post_event_home}"

	# # 		# 	#Now turn their during-storm movement path into a geo object:
	# # 		# 	@during_storm_movement = []
	# # 		# 	movement_path.each do |cluster_id|
	# # 		# 		cluster_locations[cluster_id] ||= find_median_point(@clusters[cluster_id].collect{|tweet| tweet["coordinates"]["coordinates"]})
	# # 		# 		@during_storm_movement << cluster_locations[cluster_id]
	# # 		# 	end

	# # 		# 	#At this point, we know the following things about our user:
				
	# # 		# 	# cluster_locations[:before_home]
	# # 		# 	# cluster_locations[:after_home]
	# # 		# 	# during_storm_movement

	# # 		# 	#Now we can make a couple of inferences, does the following happen?
	# # 		# 	#Place > New Place > Place (If so, give them a boosted evac score...)
	# # 		# 	index = 0

	# # 		# 	full_movement = [most_likely_home_cluster]+movement_path+[most_likely_post_event_home]
	# # 		# 	full_movement.reject!{|x| x.nil?}

	# # 		# 	#Look for patterns
	# # 		# 	until full_movement[index+3].nil? do
	# # 		# 		if full_movement[index] == full_movement[index+2]
	# # 		# 			@confidence += 10
	# # 		# 		elsif
	# # 		# 			full_movement[index]== full_movement[index+3]
	# # 		# 			@confidence += 20
	# # 		# 		end
	# # 		# 		index+=1
	# # 		# 	end

	# # 		# 	#Is the movement array symmetrical?
	# # 		# 	if (full_movement[0..full_movement.length/2] & full_movement[full_movement.length/2..-1]).present?
	# # 		# 		@confidence +=20
	# # 		# 	end

	# # 		# 	#Lets save the full movement as well:
	# # 		# 	@cluster_movement_pattern = full_movement

	# # 		# 	#Also, check their other locations...
	# # 		# 	if @cluster_locations[:before_home] == @cluster_locations[:after_home]
	# # 		# 		#User started and ended in the same place
	# # 		# 		@confidence +=10
					
	# # 		# 		if @during_storm_movement[0]==@cluster_locations[:before_home]
						
	# # 		# 			#User left from "home" location
	# # 		# 			@confidence += 10

	# # 		# 			if @during_storm_movement[-1]==@cluster_locations[:after_home]
							
	# # 		# 				#User left during storm and returned to home location
	# # 		# 				@confidence += 10

	# # 		# 				if @during_storm_movement[1] != @cluster_locations[:before_home]
	# # 		# 					@confidence += 10
	# # 		# 				end
	# # 		# 			end
	# # 		# 		end
	# # 		# 	end
	# # 		# end

	# # # 3. 

	# # 	#puts "Unclassified %: #{@unclassified_percentage}"

	# # 	end #End case that @clusters.length > 1
	
	# end #End function