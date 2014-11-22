require_relative '../config'

require 'fileio/geojson_exporter'

class EvacuationPath

	include EpicGeo
	include EpicGeo::GeoTwitterer

	attr_reader :user

	def initialize(args)
		@user = args[:user]
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

		min_dist = args[:distance] || 1000

		outfile = TweetWriter.new(filename: user.handle)

		outfile.add_point(coords_as_geojson( user.cluster_locations[ user.base_cluster ] ), {location: 'base'} )

		tweets = user.during_storm_tweets
		
		prev_point = tweets.shift

		movement = [ prev_point ]

		tweets.each do |t|
			if prev_point.point.distance(t.point) > min_dist
				movement << prev_point << t
			end
			prev_point = t
		end

		movement.each{|t| outfile.add_tweet(t) }

		outfile.add_line
		outfile.close

		return movement
	end
end


#main runtime
if __FILE__ == $0

	#Iterate over certain users and do stuff...
	users = ["Tocororo1931","Leslie_reilly","kr3at","marietta_amato","haleighbethhh","morgandube","Nikki_DeMarco","rutgersguy92","aidenscott","RedJazz43","onacitaveoz","just_teevo","leah_zara","D_Train86","Kren9","DJsonatra","mynameisluissss","JL092479","Antman73","Caitles16","danielleleiner","ACPressLee","Scott_Gaffney","ericaNAZZARO","txcoonz","KaliPorteous","OMGItssJadee","jmnzzkr","AmberAAlonzo","DomC_","mnapoli765","BleedBlue0415","TayloorKirsch","Zach_Massari10","CluelessMaven","PainFresh6","Roze_316","DevenMcCarthy","Anathebartender","forero29","KBopf","b_mazzz","compa_tijero","Christie_Jenna","DDSethi","stevewax","JoeeSmith19","iKhoiBui","kcgirl2003","ColleenBegley","Haylee_young","Aram2323,reyli24","Sara_Persiano"]

	users.each_with_index do |user_handle, index|

		#Important that we don't keep the cursor open because the timeout apparently doesn't work....
		user = Twitterer.where(:handle => user_handle).first

		puts "\nProcessing: #{user.handle} with #{user.tweet_count} geo coded tweets"
		ep = EvacuationPath.new(user: user)

		puts ( ep.home_location_point.distance ep.storm_location_point  ) / 1000
		
		puts ep.movement_profile(distance: 1000)

		# puts "First Tweet: #{user.tweets.first.date.inspect}"

	end

end