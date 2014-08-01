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
  	to_return = []
  	clusters.each do |cluster|
  		to_return << cluster.tweets
  	end
	return to_return
end