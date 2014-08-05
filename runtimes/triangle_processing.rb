#
# Triangle Processing
#
# Iterate through all users and process their geometries
#
# If Triangle logic changes, this script should be modified and run again
#

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

#Define the timewindows to split the tweets into
sandy_dates = [
  Time.new(2012,10,20), #Start of dataset
  Time.new(2012,10,28), #Start of storm
  Time.new(2012,11,1),  #End of Storm
  Time.new(2012,11,9)   #End of Dataset
]

#These names correspond with the KML styles for coloring
time_frames = ["before", "during", "after"]

#Search the Twitterer collection

Twitterer.where( :tweet_count.lte => 50).limit(nil).each_with_index do |user, index|

  # => user is a Twitterer instance.  Be sure to call user.save at the end.

  # => First, find the POIs
  # ===> Bin the tweets to create time slices based on dates (before, during, after)
  user.split_tweets_into_time_bins(sandy_dates).each_with_index do |time_slice, index|

    #This is either 'before', 'during', or 'after'
    time = time_frames[index]

    #Calculate the current POI
    dbscanner = DBScanCluster.new(time_slice, epsilon=50, min_pts=2) #This seems to work okay...
    clusters = dbscanner.run

    #Pull out the actual [x,y] point
    poi = user.get_weighted_poi_from_clusters(clusters) #Yes, passing in a hash

    #Write this point to the user
    user.set_poi(time, poi)
  end

  #Build the triangle, set values
  user.build_evac_triangle

  user.save # => Be sure to comment this in only once positive the logic is good...

  #=============== Show Status
  if (index % 10).zero?
    print "."
  elsif (index%101).zero?
    print index
  end

end #End the Search
