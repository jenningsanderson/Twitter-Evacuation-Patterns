#
# Sandbox
#
# Used for testing
#

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Prepare a KML file
# kml_outfile = KMLAuthor.new("../exports/median_locations.kml")
# kml_outfile.write_header("Sandbox Location Testing")
# write_3_bin_styles(kml_outfile.openfile)

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
Twitterer.where( :tweet_count.gte => 100).limit(10).each do |user|
  puts "User: #{user.handle}"

  puts user.tweets.class

  new_centers = get_clusters(user.tweets, 3, 10, 2)

  new_centers.each do |x,y|
    print user.point_as_epic_kml(x,y,"before",)

  end

  puts "\n--------\n"
  #user.process_geometry

  # binned_tweets = build_active_time_bins(user.tweets, sandy_dates)

  # kml_folder = {
  #     :name     => user.handle,
  #     :folders => [],
  #     :features => [user.userpath_as_epic_kml]
  #   }

  # binned_tweets.each_with_index do |time_slice, index|

    # unless time_slice.empty?
    #   median_point = find_median_point (time_slice.collect{|tweet| tweet["coordinates"]["coordinates"]})
    #
    #   user.set_poi(time_frames[index], median_point)
    #
    #   kml_folder[:features] << user.point_as_epic_kml( time_frames[index], median_point[0], median_point[1], style=time_frames[index])
    #
    #   folder = {:name => time_frames[index], :features => []}
    #
    #   #time_slice.each do |tweet|
    #   #  folder[:features] << tweet.as_epic_kml(style=time_frames[index])
    #   #end
    #
    #   kml_folder[:folders] << folder
    # end
  # end

  # user.build_evac_triangle

  # kml_outfile.write_folder(kml_folder)


  #full_user_path_json.to_json
  #puts user.individual_points.to_json
  #puts user.individual_tweets.to_json
  #puts user.full_median_point_json.to_json
  #puts user.user_points
end

# kml_outfile.write_footer
