#
# Local Sandbox
#
# Used for testing while away from epic-analytics
#

require 'mongo_mapper'
require 'epic-geo'
require 'rgeo'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Prepare a KML file
kml_outfile = KMLAuthor.new("../exports/DBScanClusters.kml")
kml_outfile.write_header("DBScan Cluster Testing")
generate_random_styles(kml_outfile.openfile, 20)

#Static Setup
MongoMapper.connection = Mongo::Connection.new #Localhost
MongoMapper.database = 'sandygeo'

#Define the timewindows to split the tweets into
# sandy_dates = [
#   Time.new(2012,10,20), #Start of dataset
#   Time.new(2012,10,28), #Start of storm
#   Time.new(2012,11,1),  #End of Storm
#   Time.new(2012,11,9)   #End of Dataset
# ]

#These names correspond with the KML styles for coloring
# time_frames = ["before", "during", "after"]


Twitterer.where( :tweet_count => 50, :affected_level => 1).limit(25).each do |user|
  print "User: #{user.handle}..."

  #Access points
  user.process_tweet_points

  user_kml_folder = {
    :name     => user.handle,
    :folders => [],
    :features => [user.userpath_as_epic_kml]
  }

  #Will need to clean this code up, but for now it may just work...
  cluster = DBScanCluster.new(user.tweets, epsilon=50, min_pts=2)

  results = cluster.run

  results.each do |k,v|
    density = calculate_density(v)
    spread = score_temporal_patterns(v)
    puts "Group: #{k} --> #{v.length} ==> #{density} ==> #{spread}==> #{density/spread}"
      #This could be the new algorithm... could be.
    this_folder = {:name => "Group #{k}", :features=>[]}
    v.each do |tweet|
      this_folder[:features] << tweet.as_epic_kml(style="r_style_#{k+1}")
    end
    user_kml_folder[:folders] << this_folder
  end

  kml_outfile.write_folder(user_kml_folder)

end

kml_outfile.write_footer