#
# A separate set of functions strictly for processing temporal data
#
#


require 'time'


#Pass an array of tweets to find temporal holes
def group_cluster_by_days(tweets)

	days = tweets.group_by{|tweet| tweet["date"].yday}.sort_by{|k,v| k}

	# days.each do |k,v|
	# 	puts "\t#{k} -> #{v.length}}"
	# end

	days
	#Now to determine appropriate methods to find appropriate holes.  How do the clusters temporally compare
	#To one another?  Can they come together to fill in the gaps?
end


def find_temporal_holes(clusters, t_scores)

	#Which days involve which clusters?

	#Should define a minimum T_Score value here for determining these holes

	clusters_by_day = {} #This will be a hash like this: 301=>1,2 302=>4, etc.

	clusters.each do |cluster_id, tweets|
		days = group_cluster_by_days(tweets)
		
		days.each do |day, tweets|
			clusters_by_day[day] ||= []
			clusters_by_day[day] << cluster_id
		end
	end

	clusters_by_day.sort_by{|k,v| k}.each do |k,v|
		puts "#{k} ==> #{v}"
	end

	starting_point = 

end




def score_temporal_patterns(tweets)
	times = tweets.collect{|tweet| tweet["date"]}
	blocks = []
	times.each do |time|
		blocks << time.hour/3
	end
	blocks.group_by{|value| value}.keys.length / times.length**2.to_f # => Essentially a measure of deviation
end