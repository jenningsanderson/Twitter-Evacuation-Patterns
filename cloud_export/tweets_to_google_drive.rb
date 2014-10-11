#Because it's meant to be run on the server
require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/deprecation'
require 'mongo_mapper'

require_relative '../config'


include EpicGeo
include EpicGeo::Writers


#Make a web directory for the user (using Epic-Geo)
web_archive = HTML::ArchiveMaker.new('NJ_UsersToCode')
web_archive.add_style # => default stylesheet
unless Dir.exists? 'NJ_UsersToCode/kml_files'
	Dir.mkdir('NJ_UsersToCode/kml_files')
end

# Make a new Google Sheet
sheets_count = 1
wb = EpicGeo::Writers::GoogleDrive::SheetMaker.new(
		collection: "HurricaneSandyEvacuationCoding",
		name: 		"NJ_UsersToCode-#{sheets_count}"
	)
_start =  Time.new(2012,10,22)
_end   =  Time.new(2012,11,14)

if ARGV[0] == "contextual"
	contextual_stream = FullContextualStreamRetriever.new(
		start_date:  _start,
		end_date:    _end,
		root_path:   config["contextual_root_path"] )
	
	MongoMapper.connection = Mongo::Connection.new(:pool_timeout=>false)
	MongoMapper.database = 'sandygeo2'
else
	contextual_stream = nil
	MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu', :pool_timeout=>false)
	MongoMapper.database = 'sandygeo2'
end


coding_sheet_headers = ["Date","Text","Geo",
	"Sentiment 1","Preparation 1","Movement 1","Reporting on Environment 1","Collective-Information 1", "Comments 1", "Geo-Cluster",
	"Sentiment 2","Preparation 2","Movement 2","Reporting on Environment 2","Collective-Information 2", "Comments 2",
	"Sentiment 2","Preparation 3","Movement 3","Reporting on Environment 3","Collective-Information 3", "Comments 3",
	"Sentiment 2","Preparation 4","Movement 4","Reporting on Environment 4","Collective-Information 4", "Comments 4",
	"Sentiment 2","Preparation 5","Movement 5","Reporting on Environment 5","Collective-Information 5", "Comments 5"]

# Get the Users we want

#users = ["ellenmrose", "DJsonatra", "nicole_edwards4", "NickeyyDees"]

users = ["Tocororo1931","Leslie_reilly","kr3at","marietta_amato","haleighbethhh","morgandube","Nikki_DeMarco","rutgersguy92","aidenscott","RedJazz43","onacitaveoz","just_teevo","leah_zara","D_Train86","Kren9","DJsonatra","mynameisluissss","JL092479","Antman73","Caitles16","danielleleiner","ACPressLee","Scott_Gaffney","ericaNAZZARO","txcoonz","KaliPorteous","OMGItssJadee","jmnzzkr","AmberAAlonzo","DomC_","mnapoli765","BleedBlue0415","TayloorKirsch","Zach_Massari10","CluelessMaven","PainFresh6","Roze_316","DevenMcCarthy","Anathebartender","forero29","KBopf","b_mazzz","compa_tijero","Christie_Jenna","DDSethi","stevewax","JoeeSmith19","iKhoiBui","kcgirl2003","ColleenBegley","Haylee_young","Aram2323,reyli24","Sara_Persiano"]

users.each_with_index do |user_handle, index|

	#Important that we don't keep the cursor open because the timeout apparently doesn't work....
	user = Twitterer.where(:handle => user_handle).first

	puts "\nProcessing: #{user.handle} with #{user.tweet_count} geo coded tweets"

	user_content = {"GeoCoded Tweet Count"    => user.tweet_count,
					"Unclassified Percentage" => user.unclustered_percentage,
					:tweets=>[]}


	#If contextual_stream is defined, then it'll grab the contextual stream, otherwise just hit DB
	if contextual_stream.nil?
		user.tweets.each do |tweet|
    		user_content[:tweets] << {:Date => tweet.date, :Text => tweet.text, :Coordinates=>tweet.coordinates["coordinates"]}
  		end
  	else
		user_content[:tweets] = contextual_stream.get_full_stream(user.tweets[0].handle)
	end
	
	unless user_content[:tweets].empty? #There's the chance it isn't found, which is bad.
		
		user_content[:tweets] = user_content[:tweets].sort_by{|tweet| tweet[:Date]}

		user_content["Total Tweets Here"] = user_content[:tweets].count

		kml_link = "kml_files/#{user.sanitized_handle}.kml"

		# #======================================================================
		#Lets write a KML file for this user.
		kml_outfile = EpicGeo::Writers::KML::KMLAuthor.new("NJ_UsersToCode/kml_files/#{user.sanitized_handle}.kml")
		kml_outfile.write_header("KML Visualized file for #{user.handle}")
		write_3_bin_styles(kml_outfile.openfile)

		#Clusters
		base_cluster  = user.cluster_locations[user.base_cluster.to_s]
		storm_cluster = user.cluster_locations[user.during_storm_cluster.to_s]
		
		points_of_interest = {:name=>"User Clusters", :features=>[]}
		points_of_interest[:features] << point_as_epic_kml(
			"Base Cluster",
			base_cluster[0],
			base_cluster[1],
			style="before")

		points_of_interest[:features] << point_as_epic_kml(
			"During Storm Cluster",
			storm_cluster[0],
			storm_cluster[1],
			style="during")

		#Add all of their tweets
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





		#Add the user to a web archive for sharable, easy viewing
		# =======================================================
		web_archive.add_user_page(user.sanitized_handle, user_content, kml_link)
		

		# #Add the user to the Google Spreadsheet
		# #======================================
		user_sheet = wb.add_worksheet(title: user.handle, headers: coding_sheet_headers)
		user_content[:tweets].each_with_index do |tweet|
			user_sheet.add_tweet(tweet)
		end
		if ((index+1)%16).zero?
			puts "------Writing new Workbook------"
			sheets_count +=1
			wb = GoogleDrive::CloudAuthor::SheetMaker.new(
				collection: "HurricaneSandyEvacuationCoding",
				name: 		"NJ_UsersToCode-#{sheets_count}"
			)
		end
		#=========================================
	end
end

#Closing Functions
web_archive.write_index