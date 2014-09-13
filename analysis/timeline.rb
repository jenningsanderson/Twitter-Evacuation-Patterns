'''
This file connects to Google Drive and aggregates all of the coding data into csv
files which are then easily ready by r for data analysis

This file also connects to the Twitterer MongoDB to get information on the clusters
'''

require 'google_drive'
require 'time'
require 'active_support'	#Not happy about having to use these two, but need the Time.change functionality
require 'rails'
require 'csv'
require 'matrix'

require 'mongo_mapper'

require_relative '../cloud_export/g_drive_functions' #I should rename this
require_relative '../cloud_export/google_sheet'   #Login
require_relative '../processing/time_processing'

require_relative '../models/Twitterer'
require_relative '../models/Tweet'

MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu', :pool_timeout=>false)
MongoMapper.database = 'sandygeo'

config,credentials = read_config
print "Connecting to Google Drive..."
session = GoogleDrive.login(credentials['google_username'], credentials['google_password'])
print "done \nConnecting to Collection..."
coll = session.collection_by_title("HurricaneSandyEvacuationCoding")
print "done\n"

# This class can turn a user coded on Google Docs into a csv
class TimeLineBuilder

	attr_reader :user_timeline

	#The names of the columns and their spreadsheet location
	@@columns = {
		:sentiment	=> 4,
		:prep     	=> 5, 
		:movement 	=> 6,
		:environment=> 7,
		:collective => 8,
		:cluster    => 10}

	#The array positions for the csv file (not columns)
	@@csv_array = {
		:sentiment	=> 0,
		:prep     	=> 1, 
		:movement 	=> 2,
		:environment=> 3,
		:collective => 4,
		:cluster    => 5}

	def initialize(worksheet)
		#Set the instance variable for sheet
		@sheet = worksheet

		#Define an empty timeline hash
		@user_timeline = {}
	end


	#Wrapper on Worksheet[] to handle empty cells easier
	def get_cell(row, column)
		val = @sheet[row, column]
		unless val == ""
			return val
		else
			return nil
		end
	end

	#Read the entire worksheet
	def read
		#Iterate over each row (Starting after headers)
		(2..(@sheet.num_rows)).each do |row|
			row #Set this as a class variable so that we can use it later too
			time = Time.parse( @sheet[row, 1] )

			#Round the time to the nearest minute for the spreadsheet
			round_time = time.change(:sec => 0)

			#Give the user a hash for this time
			@user_timeline[round_time] ||= {}

			#For each row, iterate over the columns
			@@columns.each do |column, value|
				
				#Read the value, if it's empty, get back nil
				cell_val = get_cell(row, value)
				
				unless cell_val.nil? #If nil, do nothing
					#If a value already exists for this minute, then just concatenate
					if @user_timeline[round_time][column]
						@user_timeline[round_time][column] << cell_val
					else
						@user_timeline[round_time][column] = [cell_val]
					end
				end
			end

			#We don't need to have a huge empty hash sitting around...
			if @user_timeline[round_time].empty?
				@user_timeline.delete round_time
			end
		end
	end

	#Iterate through cluster data and normalize based on distance
	def normalize_distances
		all_clusters = @user_timeline.collect{|k,v| v[:cluster]}.compact

		all_clusters.map!{|x| x.uniq[0].to_i}

		base_cluster = mode(all_clusters)

		all_clusters.uniq!

		distances_from_mode = {}

		tweeter = Twitterer.where(:handle => @sheet.title).first
		cluster_locations = tweeter.cluster_locations

		all_clusters.each do |cluster|
			distances_from_mode[cluster] = get_distance_from_point_arrays(cluster_locations[base_cluster.to_s], cluster_locations[cluster.to_s])
		end

		max = distances_from_mode.values.max

		distances_from_mode.each do |c,d|
			distances_from_mode[c] = ( 20 - ( (d / max) * 20).to_i )
		end
		
		#Now iterate over all of the values and reset!

		@user_timeline.each do |k, v|
			if v[:cluster] and !v[:cluster].nil?
				val = v[:cluster].flatten.map{|x| x.to_i}.min
				v[:cluster] = distances_from_mode[val]
			end
		end
	end

	def pretty_print_timeline

		timeline = []
		11520.times do |index|
			timeline << (Time.new(2012,10,24) + index*3600)
		end

		timeline.each do |key|
			values = ""
			if @user_timeline.has_key? time
				values = @user_timeline[time]
			end
			puts "#{key} --> #{pretty_print_values(values)}"
		end
	end

	#Prepare a row of coded data for a csv export
	def vals_to_csv_array(values)
		#Initialize empty row
		row = ["","","","",""]

		values.each do |key, val|
			if val.is_a? Array
				val.uniq!
				row[@@csv_array[key]] = val.join(",")
			else
				row[@@csv_array[key]] = val
			end

			#if key == :cluster
			#	val = [val.map{|x| x.to_i}.min]
			#end
			#row[@@csv_array[key]] = val.join(",") #Hopefully this doesn't happen
		end
		return row
	end

	def timeline_to_csv(rows, extension="")
		CSV.open("exports_3/#{@sheet.title}_#{extension}.csv", "wb") do |csv|
  			
  			#Write the csv headers
  			csv << ["Time", "Sentiment", "Preparation","Movement","Environment","Collective Information","Cluster"]
  			##csv << [Time.new(2012,10,22),0,0,0,0,0,0]
  			#Make the timeline
			timeline = []
			rows.times do |index|
				timeline << (Time.new(2012,10,22) + (index)*60) #It's rounded to the minute
			end

			#Create the rows
			timeline.each do |time|

				row_to_write = [time]

				if @user_timeline.has_key? time
					add_values = vals_to_csv_array(@user_timeline[time])
					row_to_write += add_values
				end
				csv << row_to_write
			end
		end #Close the CSV
	end	
end

#Different users to test with
#users = ["nicolelmancini","jericajazz","jefflac","SimoMarms","MoazaMatar","tlal2","BeachyIsPeachy","mattgunn","Max_Not_Mark","Rigo7x","ajc6789"]
#users = ["mattgunn"]
#users = ["Max_Not_Mark"]

#Find the spreadsheets we're looking for
session.spreadsheets.each do |spreadsheet|
	
	#Specify which sheets we want (Don't be updating all of them)
	if spreadsheet.title =~ /CodingRound2_\d+/
		
		spreadsheet.worksheets.each do |worksheet|
			begin
				if true							# This is just for going back and forth between doing all users or just some
			    #if  users.include? worksheet.title 	# Probably a better way to do this
					
					#Make a new Timeline for them
					puts "Beginning TimeLine for #{worksheet.title}"
					this_user = TimeLineBuilder.new(worksheet)
					this_user.read
					print "done..."

					this_user.normalize_distances

					#print this_user.user_timeline.collect{|k,v| v[:cluster]}

					print "writing to csv..."
					this_user.timeline_to_csv(15000, extension="norm_distances") #10 days
					print "done\n\n"
				end
			rescue => e
				puts "Something, somewhere went wrong"
				puts $!
				puts e.backtrace

			end
		end
	end
end