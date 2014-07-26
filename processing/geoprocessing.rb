#This file will hold a series of algorithms for determining different pieces of information for a user

#This is strictly for processing.  These methods should not make outside calls

GEOFACTORY = RGeo::Geographic.simple_mercator_factory

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


#K-Means Clustering
#Adapted from: https://gist.github.com/cfdrake/995804
INFINITY = 1.0/0
#
# Cluster class, represents a centroid point along with its associated
# nearby points
#
class Cluster
  attr_accessor :center, :tweets

  # Constructor with a starting centerpoint
  def initialize(center)
    @center = center.point
    @tweets = []
  end

  # Recenters the centroid point and removes all of the associated points
  def recenter!
		unless @tweets.empty?
	    xa = ya = 0
	    old_center = @center

	    # Sum up all x/y coords
	    @tweets.each do |tweet|
	      xa += tweet.point.x
	      ya += tweet.point.y
	    end

	    # Average out data
	    xa /= tweets.length
	    ya /= tweets.length

	    # Reset center and return distance moved
	    @center = GEOFACTORY.point(xa, ya)
	    return old_center.distance(center)
		else
			return 0
		end
  end
end

#
# kmeans algorithm
#
def kmeans(tweets, k, iterations=10)

	clusters = tweets.sample(k).collect{ |tweet| Cluster.new(tweet)}

  iterations.times do |index|
    # Assign points to clusters
    tweets.each do |tweet|
      min_dist = +INFINITY
      min_cluster = nil

      # Find the closest cluster
      clusters.each do |cluster|
        dist = tweet.point.distance(cluster.center)

        if dist < min_dist
          min_dist = dist
          min_cluster = cluster
        end
      end

      # Add to closest cluster
      min_cluster.tweets << tweet
    end

    clusters.each do |cluster|
      cluster.recenter!
    end

		if index < iterations-2
	    # Reset points for the next iteration
	    clusters.each do |cluster|
	      cluster.tweets = []
	    end
		end
  end
	return clusters
end


#Get clusters via k-means clustering from an array of Tweets
def get_clusters(tweets, centers=5, iterations=10)

	#Make the point object of the tweet real
	tweets.each do |tweet|
		tweet.as_point
	end

	kmeans(tweets, centers, iterations).collect{|cluster| cluster.tweets}
end

#Find the densest cluster from a cluster of tweets, this could be a home?
# --> Should check the timing of this.
def get_most_dense_cluster(tweet_clusters)
	most_dense = tweet_clusters[0]
	max_density = 0.0

	tweet_clusters.each do |tweet_cluster|
		num_tweets = tweet_cluster.length

		multi_point = GEOFACTORY.multi_point(tweet_cluster.collect{|tweet| tweet.point})
		hull = multi_point.convex_hull

		if hull.respond_to? :area
			density = num_tweets / hull.area
		else
			density = 0.0
		end

		if density > max_density
			max_density = density
			most_dense = tweet_cluster
		end
	end
	return most_dense
end
