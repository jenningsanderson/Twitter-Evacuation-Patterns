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
# print "Connecting to Google Drive..."
# session = GoogleDrive.login(credentials['google_username'], credentials['google_password'])
# print "done \nConnecting to Collection..."
# coll = session.collection_by_title("HurricaneSandyEvacuationCoding")
# print "done\n"

# Make a web directory for the user (using Epic-Geo)
web_archive = HTMLArchiveMaker.new('users_to_code')
web_archive.add_style # => default stylesheet
unless Dir.exists? 'users_to_code/kml_files'
	Dir.mkdir('users_to_code/kml_files')
end

# Make a new Google Sheet
# sheets_count = 1
# wb = SheetMaker.new(session, coll, 'Users To Code-1')

# Create an instance of the contextual stream accessor
_start = Time.new(2012,10,22)
_end   = Time.new(2012,11,14)

if ARGV[0] == "contextual"
	contextual_stream = FullContextualStreamRetriever.new(credentials["contextual_root_path"], _start, _end)
	MongoMapper.connection = Mongo::Connection.new(:pool_timeout=>false)
	MongoMapper.database = 'sandygeo'
else
	contextual_stream = nil
	MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu', :pool_timeout=>false)
	MongoMapper.database = 'sandygeo'
end

#The first 52 Users:
users = ["dogukanbiyik","kimdelcarmen","rchieB","fernanjos","nicolelmancini","Krazysoto","ailishbot","CharisseCrammer","jericajazz","KD804","jesssgilligan","theJKinz","TheAwesomeMom","bjacksrevenge","jefflac","roobs83","jds2001","SimoMarms","NYCGreenmarkets","c3nki","MoazaMatar","KiiddPhenom","sandelestepan","tlal2","BeachyisPeachy","cyantifik","FrankKnuck","mattgunn","Max_Not_Mark","JaclynPatrice","Rigo7x","ajc6789","yagoSMASH","polinchock","indavewetrust","CillaCindaplc2B","Javy_Jaz","eric13000","becaubs","enriqueskincare","Rivkind","janelles__world","CoreyKelly","josalazas","CapponiWho","JohnBakalian1","valcristdk","forero29","BobGrotz","CodyRodrigu3z","CoastalArtists","VSindha"]

# Get the Users we want

users.each_with_index do |user_handle, index|

	#Important that we don't keep the cursor open because the timeout apparently doesn't work....
	user = Twitterer.where(:handle => user_handle).first

	puts "\nProcessing: #{user.handle} with #{user.tweet_count} geo coded tweets"

	user_content = {"GeoCoded Tweet Count" => user.tweet_count,
					"Evacuation Confidence" => user.evac_conf.round, 
					"Shelter In Place Conf" => user.sip_conf.round,
					"Unclassified Percentage" => user.unclassified_percentage,
					:tweets=>[]}

	# #======================================================================
	#Lets write a KML file for this user.
	kml_outfile = KMLAuthor.new("users_to_code/kml_files/#{user.sanitized_handle}.kml")
	kml_outfile.write_header("KML Visualized file for #{user.handle}")
	write_3_bin_styles(kml_outfile.openfile)

	#Get the user's clusters:
	points_of_interest = {:name=>"User Clusters", :features=>[]}
	points_of_interest[:features] << user.point_as_epic_kml(
		"Most Likely Shelter Location",
		user.shelter_location[0],
		user.shelter_location[1],
		style="during")

	points_of_interest[:features] << user.point_as_epic_kml(
		"Before Storm Cluster",
		user.cluster_locations[user.before_home_cluster][0],
		user.cluster_locations[user.before_home_cluster][1],
		style="before")

	tweets = {:name=>"Tweets", :features=>[]}
	user.tweets.each do |tweet|
		if tweet.date > _start and tweet.date < _end
			tweets[:features] << tweet.as_epic_kml(style=nil)
		end
	end

	user_folder = {:name=>user.handle, :features=>[], :folders=> [tweets, points_of_interest]}

	kml_outfile.write_folder(user_folder)
	kml_outfile.write_footer
	# #=====================================================================


	#If contextual_stream is defined, then it'll grab the contextual stream.
	if contextual_stream.nil?
		user.tweets.each do |tweet|
    		user_content[:tweets] << {:Date => tweet.date, :Text => tweet.text}
  		end
  	else
		user_content[:tweets] = contextual_stream.get_full_stream(user.tweets[0].handle)
	end
	
	unless user_content[:tweets].empty? #There's the chance it isn't found, which is bad.
		
		user_content[:tweets] = user_content[:tweets].sort_by{|tweet| tweet[:Date]}

		user_content["Total Tweets Here"] = user_content[:tweets].count

		kml_link = nil
		kml_link = "kml_files/#{user.sanitized_handle}.kml"

		#Add the user to a web archive for sharable, easy viewing
		# =======================================================
		
		web_archive.add_user_page(user.sanitized_handle, user_content, kml_link)
		

		# # #Add the user to the Google Spreadsheet
		# # #======================================
		# user_sheet = wb.add_sheet(user.handle)
		# user_content[:tweets].each_with_index do |tweet|
		# 	user_sheet.add_tweet(tweet)
		# end
		# if ((index+1)%16).zero?
		# 	puts "------Writing new Workbook------"
		# 	sheets_count +=1
		# 	wb = SheetMaker.new(session, coll, "Users To Code-#{sheets_count}")
		# end
		# #=========================================
	end

end

#Closing Functions
web_archive.write_index