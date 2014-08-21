#
# A separate set of functions strictly for processing temporal data
#
#


require 'time'

BEFORE_SANDY = Time.new("2012","10","29").yday

AFTER_SANDY  = Time.new("2012","11","4").yday


def group_cluster_by_days(tweets)
	days = tweets.group_by{|tweet| tweet["date"].yday}.sort_by{|k,v| k}
end


def score_temporal_patterns(tweets)
	times = tweets.collect{|tweet| tweet["date"]}
	blocks = []
	times.each do |time|
		blocks << time.hour/3
	end
	blocks.group_by{|value| value}.keys.length / times.length**2.to_f # => Essentially a measure of deviation
end


#This function is a major workhorse and tries at every point to return a cop-out value.
def find_temporal_pattern(clusters, t_scores)

	clusters_by_day = {} #This will be a hash like this: 301=>1,2 302=>4, etc.

	clusters.each do |cluster_id, tweets|
		days = group_cluster_by_days(tweets)
		
		days.each do |day, tweets|
			clusters_by_day[day] ||= []
			clusters_by_day[day] << cluster_id unless t_scores[cluster_id] > 0.1 #Only want high quality zones
		end
	end

	clusters_by_day.delete_if{|k,v| v.empty?}

	valid_keys = clusters_by_day.keys.sort.reject{|x| (x < 295) or (x > 314)} #Just look at the time surrounding the Hurricane

	return 0 if valid_keys.length.zero? 	#If there are no more valid keys, return 0

	#Just for debugging
		sorted_clusters = clusters_by_day.sort_by{|k,v| k}

		sorted_clusters.each do |k,v|
			puts "#{k} ==> #{v}"
		end
	#End debugging

	#Now build a map of their locations:

	#Start before the beginning of the storm and look at when the clusters are in relation to eachother

	#Else, lets continue with the analysis
	shelter_zones = []
	zone_scores = {}

	valid_keys.each_with_index do |day, day_index|

		clusters_by_day[day].each do |zone| #Looking at zones for each day

			zone_scores[zone] ||=0
			
			#Have to start somewhere, so put first zone(s) in
			if day_index.zero?
				#Push the first zone value(s) onto the stack, but do not score the value
				shelter_zones << zone
			else
				last_val = shelter_zones.pop #Pop the last value off the stack

				if last_val == zone #This zone is equal to the last zone, cool, consistency, reward:
					shelter_zones << zone << zone #Add it back on twice
					zone_scores[zone] += 1 #Increment the zone score
				
				else #It was not the last one, so pop it off until we find it?
				
					while (last_val != zone) or (last_val != nil)
						last_val = shelter_zones.pop
					end

					#Now put this zone onto the stack
					shelter_zones << zone
				end
			end
		end
	end

	puts "================" 
	print shelter_zones
	puts "\n----------------"
	print zone_scores
	puts "\n================"


	return 1 if shelter_zones.uniq.length == 1


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

	return {:before=>1, :during=>2, :after=>3}
end



