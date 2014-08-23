#
# Sandbox
#
# Used for testing
#

require 'mongo_mapper'
require 'epic-geo'
require 'rgeo'
require 'pp'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Prepare a KML file
kml_outfile = KMLAuthor.new("../exports/new_clustering.kml")
kml_outfile.write_header("New Clustering Output")
write_3_bin_styles(kml_outfile.openfile)
generate_random_styles(kml_outfile.openfile, 10)

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
styles = ["before", "after"]
10.times do |index|
  styles << "r_style_#{index}"
end


#Search the Twitterer collection
results = Twitterer.where( 

  #:tweet_count.gte => 50,
  #:affected_level_before => 1

  :handle.in => ["Bacon_Season", "EffinwitESH", "FoxyQuant", "JayresC", "KelACampbell", "LynnKatherinex3", "Max_Not_Mark", "kriistinax33", "fredstardagreat", "honeyberk", "knowacki", "lmarks19", "marietta_amato", "mattgunn", "petemall", "ricardovice", "rishegee", "robertkohr", "rockawaytrading", "uthmanbaksh", "yawetse", "PhanieMoore", "RayDelRae", "SlaintePaddys", "anneeoanneo", "_dbourret", "c4milo", "contentmode", "cooper_smith", "derrickc82", "eelain212", "ericabrooke12"]
  #:handle.in => [ "dpickering11","robertkohr", "Xsd","jessnic0le","aimerlaterre","SteveScottWCBS","MegEHarrington","nicolelmancini","DomC_","lisuhc"]
  #:issue => 100,


  ).limit(100).sort(:handle)

puts "Found #{results.count} results..."
evac_count = 0

results.each do |user|
  puts "User: #{user.handle}..."

  user.new_location_calculation

  kml_folder = {
      :name     => user.handle,
      :folders => [],
      :features => [user.userpath_as_epic_kml]
    }

  unclassified = user.unclassified_tweets

  unclassified_folder = {:name=>"Ungrouped", :features=>[]}

  unclassified.each do |unclassified_tweet|
    unclassified_folder[:features] << unclassified_tweet.as_epic_kml(style="during")
  end

  kml_folder[:folders] << unclassified_folder

  count = 0
  user.clusters.sort_by{|k,v| v.length}.reverse.each do |k,v|
    this_folder = {:name=>k.to_s, :features=>[]}
    
    v.each do |tweet|
      this_folder[:features] << tweet.as_epic_kml(style=styles[count])
    end

    kml_folder[:folders] << this_folder

    count +=1
  end
  
  if user.shelter_in_place
    puts "\tShelter In Place"
  elsif user.unclassifiable
    puts "\tNot Enough Information"
  else
    puts "\tMoved: #{user.confidence}"
    evac_count +=1
  end

  puts "\n"

  kml_outfile.write_folder(kml_folder)


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
end

puts "Found #{evac_count} evacuators"

kml_outfile.write_footer
