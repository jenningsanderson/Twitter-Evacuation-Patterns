# KML Export
#
# Write a KML file of Users and their tweets from the Twitterers collection
#

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'

filename = "new_clustering_algorithm.kml"
limit = 10
min_tweets = 5

#Prepare a KML file
puts "Starting the following KML File: #{filename}"

kml_outfile = KMLAuthor.new("../exports/#{filename}")
kml_outfile.write_header("KML Output of Specific Users")

write_3_bin_styles(kml_outfile.openfile)
#Should also add a style here

#Prepare the HTML export
html_export = HTML_Writer.new("../exports/#{filename}.html")
html_export.write_header('Exported along with KML file')

#Static Setup
MongoMapper.connection = Mongo::Connection.new #('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

sandy_dates = [
  Time.new(2012,10,19), #Start of dataset
  Time.new(2012,10,28), #Start of storm
  Time.new(2012,11,1),  #End of Storm
  Time.new(2012,11,10)   #End of Dataset
]

#These names correspond with the KML styles for coloring
time_frames = ["before", "during", "after"]

#Search the Twitterer collection
results = Twitterer.where(
  :affected_level => 1,
  :before_after.lte=> 100,
  :isoceles_ratio.gte => 0.99,
  :isoceles_ratio.lte => 1.01,
  :triangle_perimeter.gte=> 1000,
  :triangle_perimeter.lte=> 500000,
  :before_tweet_count.gte=> min_tweets,
  :during_tweet_count.gte=> min_tweets,
  :after_tweet_count.gte=> min_tweets

).limit(limit)

puts "Number of results for this query: #{results.count}"

results.each do |user|

  puts "Processing User: #{user.handle}..."

  binned_tweets = user.split_tweets_into_time_bins(sandy_dates)

  user_kml_folder = {
    :name     => user.handle,
    :folders => [],
    :features => [user.userpath_as_epic_kml]
  }

  binned_tweets.each_with_index do |time_slice, index|

    time = time_frames[index]

    folder = {:name => time, :features => []}

    #puts "In this folder: #{time_slice.length}"

    time_slice.each do |tweet|
     folder[:features] << tweet.as_epic_kml(style=time)
    end

    #poi = user.instance_eval(time.to_s)

    #Calculate a new poi from the algo
    #Run clusters

    dbscanner = DBScanCluster.new(time_slice, epsilon=50, min_pts=2)
    clusters = dbscanner.run

    poi = get_weighted_poi_from_clusters(clusters.values)

    user_kml_folder[:folders] << folder

    user_kml_folder[:features] <<
      user.point_as_epic_kml(time, poi[0],poi[1],time)
  end

  #puts "Total Tweets: #{user.tweets.count}"

  #Finished with this user, write the folder
  kml_outfile.write_folder(user_kml_folder)
  print "done\n"
end

#Finally, close the KML file
kml_outfile.write_footer
puts "Finished writing the file: #{filename}"
