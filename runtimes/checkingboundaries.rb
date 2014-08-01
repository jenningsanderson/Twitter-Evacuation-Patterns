#
# Sandbox
#
# Used for testing
#

require 'mongo_mapper'
require 'epic-geo'
require 'rgeo'

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

points=[[-71.630859375,41.492120839687786],[-73.19091796875,41.31907562295136],[-74.37744140625,40.763901280945866],[-75.267333984375,40.08647729380881],[-75.73974609375,39.66491373749128],[-75.552978515625,39.04478604850143],[-75.1904296875,38.47079371120379],[-74.827880859375,38.53097889440026],[-74.080810546875,39.639537564366684],[-73.916015625,40.405130697527866],[-73.948974609375,40.50544628405211],[-73.245849609375,40.55554790286311],[-72.21313476562499,40.88029480552824],[-71.455078125,41.178653972331674],[-71.56494140625,41.4509614012039],[-71.630859375,41.492120839687786]]

boundary_points = []

points.each do |point|
  boundary_points << GEOFACTORY.point(point[0],point[1])
end

boundary = GEOFACTORY.multi_point(boundary_points).convex_hull

counter = 0

#Search the Twitterer collection
Twitterer.where( :tweet_count.gte => 1).limit(nil).each_with_index do |user, index|
  #print "User: #{user.handle}..."

  #Access points
  user.process_tweet_points

  #Make the user linestring
  user_string = GEOFACTORY.line_string(user.points)

  user.affected_level = 10

  #Check it
  val = user_string.intersects? boundary
  if val
    counter+=1
    user.affected_level = 1
  end

  user.save

  if (index % 100).zero?
    print "."
  elsif (index%1001).zero?
    print "#{counter} / #{index+1}"
  end
end
