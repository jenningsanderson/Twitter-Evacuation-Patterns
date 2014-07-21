#This file will hold a series of algorithms for determining different pieces of information for a user

#This is strictly for processing.  These methods should not make outside calls

#Algorithm adopted from Andrew Hardin's C# function.
# Given an array of points, this function will sort the x,y coordinates and
# return the median point.  This seems to work better than an averaging
# function because the median point will not geographically consider far outlying
# points.
def find_median_point(points_array)
	x = []
	y = []
	points_array.each do |point|
		x << point[0]
		y << point[1]
	end
	x.sort!
	y.sort!
	if (points_array.length % 2).zero?
		mid = x.length/2
		return [ (x[mid]+x[mid-1]) /2.0, (y[mid]+y[mid-1])/2.0]
	else
		mid = x.length/2
		return [x[mid],y[mid]]
	end
end


#Given an array of Tweet objects and a list of dates, this function
# returns an array of size dates.length-1 which are binned groups of the tweets
# in which the tweets in each bin were the tweets that occured in the most active
# 1/8th of the days.
#
# The tweets returned should not be solely considered for analysis, but rather used
# in conjunction with a median or average location finding function to determine
# the user's general geographic activity.
def build_active_time_bins(tweets, dates)

	#Pull out the times of each tweet.
	times = tweets.collect{|tweet| tweet["date"]}

	#Find the most active part of this user's daily activity
	hours_of_day = [0]*8
	times.each do |time|
		hours_of_day[time.hour / 3] += 1
	end
	most_active_hours = hours_of_day.index hours_of_day.max

	#Get the tweets that occured in that chunk of time
	pert_tweets = tweets.select{|tweet| ( tweet["date"].hour / 3) == most_active_hours}

	binned_tweets = []

	#Now separate the tweets into bins:
	(0..dates.length-2).each do |index|
		binned_tweets << pert_tweets.select{|tweet| tweet["date"] > dates[index] and tweet["date"] < dates[index+1]}
		#pert_tweets.delete_if{ |tweet| tweet["date"] > dates[index] and tweet["date"] < dates[index+1] }
	end
	return binned_tweets
end
