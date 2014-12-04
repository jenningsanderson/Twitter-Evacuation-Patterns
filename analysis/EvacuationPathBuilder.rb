require_relative '../config'

require 'fileio/geojson_exporter'
require 'analysis/TimeLineBuilder'

include EpicGeo

COLLECTION = "HurricaneSandyEvacuationCoding"
PREFIX = /NJ_UsersToCode-\d+/

#=Qualitative Coding Class
#
#Holds a GoogleDrive connection in order to write GeoJSON evacuation
#paths to visualize the appropriate coding schemes
class QualitativeCoding

	attr_reader :user, :sheet, :qual_data

	def initialize(args={})
		@@connection ||= GoogleDriveAccess.new(collection: COLLECTION)
		@user = args[:user]
		@sheet = get_sheet
	end

	def get_sheet
		#Iterate over each spreadsheet in the collection
		@@connection.collection.spreadsheets.each do |spreadsheet|

			#Check we're within the scope we want
			if spreadsheet.title =~ PREFIX

				#Now iterate over each sheet in the spreadsheet
				spreadsheet.worksheets[1..-1].each do |worksheet|
					
					if worksheet.title == user
						return worksheet
					end
				end
			end
		end
		return nil
	end

	#Fall back on the TimeLineBuilder to do the heavy lifting and parsing
	#including the substitutions
	def parse_sheet
		timeline = TimeLineBuilder.new(worksheet: sheet)
		timeline.read
		@qual_data = timeline.user_timeline
	end
end



#=Evacuation Path Visualizer
#
#Build a movement profile for a user who _probably_ evacuated.
class EvacuationPath

	include EpicGeo
	include EpicGeo::GeoTwitterer

	attr_reader :user, :qc

	def initialize(args)
		@user = args[:user]
		post_initialize
	end

	def post_initialize
		@qc ||= QualitativeCoding.new(user: user.handle)
	end

	def get_timeline
		qc.parse_sheet
	end

	# Returns the user's home location point as an RGEO point
	def home_location_point
		coords_as_point user.cluster_locations[user.base_cluster]
	end

	# Returns the shelter location as an RGEO point
	def storm_location_point
		coords_as_point user.cluster_locations[user.during_storm_cluster]
	end

	#Builds a GeoJSON movement profile for the user
	def movement_profile(args={})

		min_dist = args[:distance] || 1000 #Set a default minimum distance (1km)

		outfile = TweetWriter.new(filename: user.handle, write_directory: "../assets/qual_maps/") #Initialize an export file for visualizing

		outfile.add_point(coords_as_geojson( user.cluster_locations[ user.base_cluster ] ), {location: 'base'}) #Add the base location

		tweets = user.during_storm_tweets #Get just the tweets from during the storm
		
		prev_point = tweets.shift

		outfile.add_tweet(prev_point)

		tweets.each do |t|

			if prev_point.point.distance(t.point) > min_dist
				outfile.add_tweet(t, get_nearest_coding_data(t.date))
			end
			
			prev_point = t
		end

		outfile.add_line
		outfile.close
	end

	#Can we attach qualitative coding pieces to geographic points?
	def get_nearest_coding_data(target_time)
		#Iterate through each tweet and find times that match
		possible_codings = {}
		
		qc.qual_data.each do |time, values|

			#Compare target time to the qual data found:
			if (target_time - time).abs < 60
				puts "Target: #{target_time}, #{time}, #{target_time - time}"#, #{values}"
				possible_codings.merge! values
			end
		end
		flattened = {}
		possible_codings.each {|k,v| flattened[k] = v.flatten.uniq }
		puts flattened
		return {coding: flattened}
	end

end


#main runtime
if __FILE__ == $0


	#Iterate over certain users and do stuff...
	users = ["Sara_Persiano","Tocororo1931","danielleleiner","Leslie_reilly","kr3at","marietta_amato","haleighbethhh","morgandube","Nikki_DeMarco","rutgersguy92","aidenscott","RedJazz43","onacitaveoz","just_teevo","leah_zara","D_Train86","Kren9","DJsonatra","mynameisluissss","JL092479","Antman73","Caitles16","danielleleiner","ACPressLee","Scott_Gaffney","ericaNAZZARO","txcoonz","KaliPorteous","OMGItssJadee","jmnzzkr","AmberAAlonzo","DomC_","mnapoli765","BleedBlue0415","TayloorKirsch","Zach_Massari10","CluelessMaven","PainFresh6","Roze_316","DevenMcCarthy","Anathebartender","forero29","KBopf","b_mazzz","compa_tijero","Christie_Jenna","DDSethi","stevewax","JoeeSmith19","iKhoiBui","kcgirl2003","ColleenBegley","Haylee_young","Aram2323,reyli24"]

	users.each_with_index do |user_handle, index|

		begin

			#Important that we don't keep the cursor open because the timeout apparently doesn't work....
			user = Twitterer.where(:handle => user_handle).first

			puts "\nProcessing: #{user.handle} with #{user.tweet_count} geo coded tweets"
			ep = EvacuationPath.new(user: user)

			puts "Base -> Storm Location: #{( ep.home_location_point.distance ep.storm_location_point  ) / 1000 } km"

			ep.get_timeline

			#ep.match_points

			ep.movement_profile(distance: 100)

			# puts "First Tweet: #{user.tweets.first.date.inspect}"
		rescue => e
			puts "error with #{user_handle}"
			puts $!
			#puts e.backtrace
		end
	end
end