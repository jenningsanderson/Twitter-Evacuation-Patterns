#
# KMeans Time Bin Triangles
#
# The current main algorithm for triangle building
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
counter = 0
Twitterer.where( :triangle_area => 0).limit(10000).sort(:tweet_count).each_with_index do |user, index|
  print "Beginning #{user.handle}: "

  #Must use proper error handling because issues have been known to arise
  begin

    #Make the tweet points real objects
    user.process_tweet_points

    #First, bin the tweets by time
    binned_tweets = user.split_tweets_into_time_bins(sandy_dates)

    #Iterate through the time bins
    user.issue = 0
    binned_tweets.each_with_index do |time_bin, index|

      if time_bin.length.zero?
        user.issue = 1
        next
      end

      #Declare as either 'before', 'during', 'after'
      time = time_frames[index]

      #Identify clusters in each bin
      clusters = kmeans(time_bin, 5, 10)

      #Find the densest cluster
      most_dense_cluster = get_most_dense_cluster(clusters)

      #Find the median of that cluster
      poi = find_median_point(most_dense_cluster.collect{ |tweet| tweet["coordinates"]["coordinates"]})

      #Write this POI to the user (Just the lat/lon)
      user.set_poi(time,poi)
    end

    #Calculate the evacuation triangle
    user.build_evac_triangle

    #Status update
  rescue => e
    print "F\n"
    puts $!
    puts e.backtrace
    user.issue = 0
  end #End the error handling

  if user.issue.zero?
      counter += 1
      print "..Success"
    else
      print "..F"
    end

  user.save
  puts ""

  if (index % 10).zero?
    puts "\t Status: #{index} processed, #{counter} were successful (#{counter.to_f/(index+1)})"
  end

end #End the Search

