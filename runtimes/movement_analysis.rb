# Movement Analysis
#
# This script is for testing/finalizing the evacuation classifying method.
#
#

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

filename = "user_movement_analysis"

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

#Lets also write a KML file for visualizing this information
# kml_outfile = KMLAuthor.new("../exports/#{filename}.kml")
# kml_outfile.write_header("KML Output of Specific Users")
# generate_random_styles(kml_outfile.openfile, 30)
# write_3_bin_styles(kml_outfile.openfile)


def add_user_cluster_to_kml(user, kml_file)

	user_folder = {:name=> user.handle, :folders=>[], :features=>[]}

	unclassified = {:name=>"Unclassified", :features=>[]}
	user.unclassified_tweets.each do |tweet|
		unclassified[:features] << tweet.as_epic_kml(style="after")
	end
	user_folder[:folders] << unclassified

	user.clusters.keys.each_with_index do |k, index|
		this_folder = {:name=>k, :features=>[]}
		user.clusters[k].each do |tweet|
			this_folder[:features] << tweet.as_epic_kml(style="r_style_#{index+1}")
		end
		user_folder[:folders] << this_folder
	end
	kml_file.write_folder(user_folder)
end


results = Twitterer.where( 
	
	:path_affected => true,
	:unclassifiable.ne => true,
	:t_scores => nil

).limit(nil).sort(:tweet_count)

puts "Found #{results.count} users"

results.each_with_index do |user, index|

	puts user.handle
	puts "------------------"

	user.get_and_store_clusters

	user.issue = 1000

	user.save

	#add_user_cluster_to_kml(user, kml_outfile)

	puts "==================\n\n"

end

# kml_outfile.write_footer
