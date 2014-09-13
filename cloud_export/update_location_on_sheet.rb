#Because it's meant to be run on the server
require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/deprecation'
require 'mongo_mapper'

#Requirements
require 'google_drive'
require 'time'
require 'epic-geo'

#require_relative '/Users/jenningsanderson/Documents/epic-geo/lib/epic-geo'

#Eventually this will get published to epic-geo
require_relative 'g_drive_functions'
require_relative 'google_sheet'
require_relative 'full_contextual_stream'
require_relative '../models/twitterer'
require_relative '../models/tweet'


config,credentials = read_config
print "Connecting to Google Drive..."
session = GoogleDrive.login(credentials['google_username'], credentials['google_password'])
print "done \nConnecting to Collection..."
coll = session.collection_by_title("HurricaneSandyEvacuationCoding")
print "done\n"

MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu', :pool_timeout=>false)
MongoMapper.database = 'sandygeo'

#The first 52 Users:
users = ["dogukanbiyik","kimdelcarmen","rchieB","fernanjos","nicolelmancini","Krazysoto","ailishbot","CharisseCrammer","jericajazz","KD804","jesssgilligan","theJKinz","TheAwesomeMom","bjacksrevenge","jefflac","roobs83","jds2001","SimoMarms","NYCGreenmarkets","c3nki","MoazaMatar","KiiddPhenom","sandelestepan","tlal2","BeachyisPeachy","cyantifik","FrankKnuck","mattgunn","Max_Not_Mark","JaclynPatrice","Rigo7x","ajc6789","yagoSMASH","polinchock","indavewetrust","CillaCindaplc2B","Javy_Jaz","eric13000","becaubs","enriqueskincare","Rivkind","janelles__world","CoreyKelly","josalazas","CapponiWho","JohnBakalian1","valcristdk","forero29","BobGrotz","CodyRodrigu3z","CoastalArtists","VSindha"]

# Get the Users we want

users = users

users.each_with_index do |user_handle, index|
	puts "Processing user: #{user_handle}"

	session.spreadsheets.each do |spreadsheet|
	
		#Specify which sheets we want (Don't access all of them)
		if spreadsheet.title =~ /CodingRound2_\d+/
			
			spreadsheet.worksheets.each do |worksheet|
				if worksheet.title == user_handle

					#Now we have our worksheet as "worksheet"
					#Iterate through the worksheet:
					(2..worksheet.num_rows).each do |row|
					#(2..worksheet.num_rows).each do |row|
						coords = worksheet[row,3]
						unless coords == "------"
							coords = coords[1..-2].split(",")

							#Lets see what's going on with this user's coords
							user = Twitterer.where(:handle => user_handle).first
							puts user.handle

							this_tweet_point = GEOFACTORY.point(coords[0].strip.to_f,coords[1].strip.to_f)
							this_cluster = nil
							min_dist = 100000
							max_dist = 500	#We don't care if it's more than 500 meters away
							min_clust = nil

							#we only care about cluster locations that are numbered:
							pert_clusters = user.cluster_locations.select{|k,v| k=~ /\d+/}

							pert_clusters.each do |id, cluster_coords|
								unless cluster_coords.nil? #Hopefully this isn't the case

									cluster = GEOFACTORY.point(cluster_coords[0], cluster_coords[1])
									dist = this_tweet_point.distance(cluster)
									
									if dist < min_dist 
										min_dist = dist
										min_clust = id
									end
								end
							end
							unless min_clust.nil? or min_dist > max_dist
								puts "Cluster: #{min_clust}"
								worksheet[row,10] = min_clust
							else
								puts "Must have been moving..."
								worksheet[row,10] = ""
							end
						end
					end
					worksheet.save
				end
			end
		end
	end
end