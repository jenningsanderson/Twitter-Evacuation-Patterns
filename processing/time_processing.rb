#
# A separate set of functions strictly for processing temporal data
#
#


require 'time'


#Pass an array of tweets to find temporal holes
def find_temporal_holes(tweets)

	days = tweets.group_by{|tweet| tweet["date"].yday}.sort_by{|k,v| k}

	days.each do |k,v|
		puts "\t#{k} -> #{v.length}}"
	end


	#Now to determine appropriate methods to 

end


def score_temporal_patterns(tweets)
	times = tweets.collect{|tweet| tweet["date"]}
	blocks = []
	times.each do |time|
		blocks << time.hour/3
	end
	blocks.group_by{|value| value}.keys.length / times.length**2.to_f # => Essentially a measure of deviation
end