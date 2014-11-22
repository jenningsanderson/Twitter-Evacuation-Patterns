#
# Moving time_processing functions to this module for clarity
#
module TimeProcessing
	
	require 'time'

	#Returns a hash with day_of_year as keys and arrays of tweet objects as values
	def group_tweets_by_day(tweets)
		days = tweets.group_by{|tweet| tweet["date"].yday}.sort_by{|k,v| k}
	end


	#Deprecated
	def score_temporal_patterns(tweets)
		times = tweets.collect{|tweet| tweet["date"]}
		blocks = []
		times.each do |time|
			blocks << time.hour/3
		end

		blocks.group_by{|value| value}.keys.length / times.length**2.to_f # => Essentially a measure of deviation
	end


	#Given a list of tweets, return the number of tweets that exist in time bins with > 25% activity
	def tweet_regularity(tweets)
		times = tweets.collect{ |tweet| tweet.date }
		tweet_count = times.length.to_f
		blocks = []

		#Split the day into 8 3 hour chunks
		groups = times.group_by{|time| (time.hour/3)}

		#Create array of time bin probabilities
		norm_vals = groups.collect{ |k,v| v.length / tweet_count }
		
		#Sum the percentages that are above 30 percent. #Just above 12.5, which is chance
		score = norm_vals.select{|v| v > 0.25 }.inject(:+)

		#Return the number of tweets that are above 1/4
		unless score.nil?
			return score * tweet_count
		else
			return 0
		end
	end

	#
	def sort_clusters_by_day(clusters)
		clusters_by_day = {} #This will be a hash like this: 301=>1,2 302=>4, etc.

		clusters.each do |cluster_id, tweets|
			days = group_cluster_by_days(tweets)
			
			days.each do |day, tweets|
				clusters_by_day[day.to_s] ||= []
				clusters_by_day[day.to_s] << cluster_id # unless t_scores[cluster_id] > 0.1 #Only want high quality zones
			end
		end
		return clusters_by_day
	end


	#This function is a major workhorse and tries at every point to return a cop-out value.
	def find_temporal_pattern(clusters, t_scores)

		clusters_by_day = sort_clusters_by_day(clusters)

		clusters_by_day.delete_if{|k,v| v.empty?}

		valid_keys = clusters_by_day.keys.sort.reject{|x| (x < 295) or (x > 314)} #Just look at the time surrounding the Hurricane

		return 0 if valid_keys.length.zero? 	#If there are no more valid keys, return 0


		valid_keys.each do |key|
			puts "#{key} => #{clusters_by_day[key]}"
		end

		#Else, lets continue with the analysis
		shelter_zones = []
		zone_scores = {}

		# valid_keys.each_with_index do |day|

		# 	#If more than one zone per day, handle that separately

		# 	if clusters_by_day[day].length == 1
		# 		zone = clusters_by_day[day][0]
		# 		zone_scores[zone] ||=0

		# 		#Have to start somewhere, so put first zone(s) in
		# 		if shelter_zones.empty?
		# 			#Push the first zone value(s) onto the stack, but do not score the value
		# 			shelter_zones.unshift(zone)
				
		# 		else
		# 			if shelter_zones.include? zone
		# 				weight = shelter_zones.index(zone)+1 #This will determine where it is, relatively
		# 				zone_scores[zone] += (1.to_f / weight)
		# 			end
		# 			shelter_zones.unshift(zone) #Add the zone to the front
		# 		end
		# 	else
		# 		#We have a day with multiple zones
		# 		if shelter_zones.empty?
					
		# 			#Create the shelter_zones array with these datapoints
		# 			shelter_zones = clusters_by_day[day] 
		# 		else
		# 			#Need to find the indexes and take the lower one, then push that value.
		# 			prev_zone = clusters_by_day[day].shift #Pop the zone off the front
		# 			zone_scores[prev_zone] ||=0
		# 			prev_weight = 10000
		# 			if shelter_zones.include? prev_zone
		# 				prev_weight = shelter_zones.index(prev_zone)+1
		# 			end

		# 			until clusters_by_day[day].empty? do
		# 				this_zone = clusters_by_day[day].shift
		# 				zone_scores[this_zone] ||=0
		# 				if shelter_zones.include? this_zone
		# 					this_weight = shelter_zones.index(this_zone)+1
							
		# 					if this_weight < prev_weight
		# 						prev_weight = this_weight
		# 						prev_zone = this_zone
		# 					end
		# 				end
		# 			end
		# 			shelter_zones.unshift(prev_zone)
		# 			unless prev_weight == 10000
		# 				zone_scores[prev_zone] += (1.to_f / prev_weight)
		# 			end
		# 		end
		# 	end
		# end

		# if shelter_zones.uniq.count==1
		# 	return shelter_zones.uniq
		# end

		# return shelter_zones.reverse!
	end


	def score_cluster_pattern(clusters, t_scores, before_home_cluster)

		#Weights
		distribution_weights = {
			300 => 1,
			301 => 1,
			302 => 2,		#October 28, 2012
			303 => 3,		#October 29, 2012
			304 => 5,		#October 30, 2012
			305 => 8,		#October 31, 2012
			306 => 6,		#November 1, 2012
			307 => 3,		#November 2, 2012
			308 => 2,		#November 3, 2012	LynnCatherineX3 came back home 
			309 => 1,		#November 4, 2012
			310 => 1,
			311 => 1,
			312 => 1,
			313 => 1,
			314 => 1,
		}

		probable_before_locations = []
		probable_evac_locations   = []
		probable_after_locations  = []

		clusters.sort_by{|k,v| k.to_i}.each do | day, clusters_that_day |

			yday = day.to_i

			clusters_that_day.each do |indiv_cluster|
				unless t_scores[indiv_cluster] > 0.1
					if yday < 303 
					 	probable_before_locations << ([indiv_cluster] * distribution_weights[yday])
					elsif yday > 308
						probable_after_locations << ([indiv_cluster] * distribution_weights[yday])
					else
						# if probable_before_locations.include? indiv_cluster
						probable_evac_locations << ([indiv_cluster] * distribution_weights[yday])
						# else
						# 	probable_evac_locations << ([indiv_cluster] * distribution_weights[yday] * 2)
						# end
					end
				end
			end
		end

		return probable_before_locations.flatten, probable_evac_locations.flatten, probable_after_locations.flatten

	end

	def find_before_home(clusters)
		before_clusters = clusters.reject{|k,v| k.to_i > 302}
		#puts before_clusters
		unless before_clusters.empty?
			return mode(before_clusters.values.flatten)
		else
			return nil
		end
	end

	def find_after_home(clusters)
		after_clusters = clusters.reject{|k,v| k.to_i < 314}
		#puts after_clusters
		unless after_clusters.empty?
			return mode(after_clusters.values.flatten)
		else
			return nil
		end
	end

end








'''Deprecated Code'''

# def find_best_before_cluster(clusters, t_scores)
	
# 	clusters_by_day = {} #This will be a hash like this: 301=>1,2 302=>4, etc.

# 		clusters.each do |cluster_id, tweets|
# 			days = group_cluster_by_days(tweets)
			
# 			days.each do |day, tweets|
# 				clusters_by_day[day] ||= []
# 				clusters_by_day[day] << cluster_id unless t_scores[cluster_id] > 0.1 #Only want high quality zones
# 			end
# 		end

# 		clusters_by_day.delete_if{|k,v| v.empty?}

# 		clusters_by_day.delete_if{|k,v| k > 302 } #Get all points from before the Hurricane

# 		return nil if clusters_by_day.keys.length.zero? 	#If there are no more valid keys, return 0

# 		return mode(clusters_by_day.values)
	
# end


# def find_best_after_cluster(clusters, t_scores)
# 	clusters_by_day = {} #This will be a hash like this: 301=>1,2 302=>4, etc.

# 		clusters.each do |cluster_id, tweets|
# 			days = group_cluster_by_days(tweets)
			
# 			days.each do |day, tweets|
# 				clusters_by_day[day] ||= []
# 				clusters_by_day[day] << cluster_id unless t_scores[cluster_id] > 0.1 #Only want high quality zones
# 			end
# 		end
# 		clusters_by_day.delete_if{|k,v| v.empty?}
# 		clusters_by_day.delete_if{|k,v| k < 314 } #Get all points after the Hurricane
# 		return nil if clusters_by_day.keys.length.zero? 	#If there are no more valid keys, return 0
# 		return mode(clusters_by_day.values)
# end



	#One attempt:
	#For simplicity, lets hardcode in the landfall of the Storm:
	# before_zones = clusters_by_day.select{|k,v| k < BEFORE_SANDY}.values.flatten.group_by{|x| x}
	# clusters_by_day.delete_if{|k,v| k < BEFORE_SANDY}

	# during_zones = clusters_by_day.select{|k,v| k < AFTER_SANDY }.values.flatten.group_by{|x| x}
	# clusters_by_day.delete_if{|k,v| k < AFTER_SANDY}

	# weighted_before_zones = {}
	# before_zones.each do |zone,zone_array|
	# 	weighted_before_zones[zone] = zone_array.length * t_scores[zone]**2
	# end

	# weighted_during_zones = {}
	# during_zones.each do |zone,zone_array|
	# 	weighted_during_zones[zone] = zone_array.length**2 * t_scores[zone]**3 #Extra Weighting for Evac Times
	# end

	# #puts "Before Landfall Zones: #{before_zones}"
	# puts "Weighted Before Score: #{weighted_before_zones}"

	# puts "Weighted During Score: #{weighted_during_zones}"

	# #puts "Best before zone: #{weighted_before_zones.min_by(&:last)}"

	# before_zone = weighted_before_zones.min_by(&:last)[0]
	# during_zone = weighted_during_zones.min_by(&:last)[0]

	# puts "Before Zone: #{before_zone}"
	# puts "During Zone: #{during_zone}"

	# if before_zone == during_zone
	# 	puts "Shelter In Place"
	# else
	# 	puts "Moved"
	# end

	# location_scores = {}

	# first_location = sorted_clusters.first[1]
	
	# first_location.each do |location|
	# 	catch :next_location do 
	# 		location_scores[location] = 0

	# 		#Now iterate through the sorted_clusters and see which location wins
	# 		sorted_clusters.each do |k,v|
				
	# 			throw :next_location unless v.include? location
	# 			location_scores[location] += 1
	# 		end #end sorted_clusters iteration
	# 	end #next location catch
	# end

	# puts location_scores
