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
# kml_outfile = KMLAuthor.new("../exports/DBScanClusters.kml")
# kml_outfile.write_header("DBScan Cluster Testing")
# generate_random_styles(kml_outfile.openfile, 20)

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
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


user_array = [ "10296692", "101937602", "10947242", "11089882", "112914465", "115402829", "11702052", "123905093", "12967532", "132016851", "133031798", "138040179", "14239599", "14308508", "145231158", "14570815", "146062518", "147070682", "14850313", "153988612", "15416112", "159657272", "159875851", "16227947", "16296246", "16303325", "16362685", "16638650", "16676499", "16824104", "16856879", "16975334", "17004113", "17162311", "172119315", "17638843", "17893558", "17913519", "18040825", "18113822", "187092357", "18837581", "18902267", "19304992", "19368410", "19409508", "209151977", "20940614", "21155077", "21359940", "21714240", "222895392", "226425184", "226428781", "226847420", "22833365", "22961538", "23120005", "237073998", "24128194", "24252370", "24583446", "24633201", "248387386", "261502505", "267723397", "27363375", "281832935", "28288155", "291910836", "29906317", "30088983", "30586066", "30868217", "310171149", "31107395", "313352511", "32254092", "34613882", "357905303", "360411897", "374592699", "384918074", "408930460", "43468317", "435878875", "437093226", "43847317", "442948981", "469339691", "470431443", "471720776", "49846765", "50041345", "50109029", "5147551", "5237281", "54096848", "54249904", "545476724", "561466624", "5730902", "575876070", "5947152", "6149582", "64252487", "6434092", "6585382", "68336363", "68478069", "73632124", "738012205", "76447685", "779106277", "7851542", "84723809", "867212690", "873918324", "9626672", "97135532"]

user_array.each do |id_str|
  user = Twitterer.where(:id_str=> id_str).first
  user.issue = 100
  user.save
end

# Twitterer.where( :tweet_count => 50, :affected_level => 5).limit(10).each do |user|
#   print "User: #{user.handle}..."

#   #Access points
#   user.process_tweet_points

#   user_kml_folder = {
#     :name     => user.handle,
#     :folders => [],
#     :features => [user.userpath_as_epic_kml]
#   }

#   #Will need to clean this code up, but for now it may just work...
#   cluster = DBScanCluster.new(user.tweets, epsilon=50, min_pts=2)

#   results = cluster.run

#   results.each do |k,v|
#     density = calculate_density(v)
#     spread = score_temporal_patterns(v)
#     puts "Group: #{k} --> #{v.length} ==> #{density} ==> #{spread}==> #{density/spread}"
#       #This could be the new algorithm... could be.
#     this_folder = {:name => "Group #{k}", :features=>[]}
#     v.each do |tweet|
#       this_folder[:features] << tweet.as_epic_kml(style="r_style_#{k+1}")
#     end
#     user_kml_folder[:folders] << this_folder
#   end

#   kml_outfile.write_folder(user_kml_folder)

# end

# kml_outfile.write_footer
