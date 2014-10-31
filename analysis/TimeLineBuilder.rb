#
# Given a worksheet from Google Drive, this will build a timeline on a per-user basis.
#
# What it Does:
# => Sanitization for multiple Values #TODO
# => Writes the spreadsheets down to CSV by minute
#

require 'csv'

#require 'matrix'

class TimeLineBuilder

	attr_reader :user_timeline, :write_directory, :sheet

	# The names of the columns and their spreadsheet location
	@@columns = {
		:Sentiment		=> 4,
		:Preparation  	=> 5, 
		:Movement 		=> 6,
		:Environment 	=> 7,
		:Collective 	=> 8 }

	# The array positions for the csv file (not columns)
	@@csv_array = {
		:Sentiment	 => 0,
		:Preparation => 1, 
		:Movement 	 => 2,
		:Environment => 3,
		:Collective  => 4 }

	def initialize(args)
		#Set the instance variable for sheet
		@sheet = args[:worksheet]

		@write_directory = args[:write_directory] || Time.new.to_s

		unless Dir.exists? write_directory
			Dir.mkdir write_directory
		end

		#Define an empty timeline hash
		@user_timeline = {}
	end

	def csv_array
		@@csv_array
	end

	def columns
		@@columns
	end


	#Wrapper on Worksheet[] to handle empty cells easier
	def get_cell(row, column)
		val = @sheet[row, column]
		unless val == ""
			return val.split(',').collect{|x| x.strip}
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
			columns.each do |column, value|
				
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

	#Prepare a row of coded data for a csv export
	def vals_to_csv_array(values)
		#Initialize empty row
		row = ["","","","",""]

		values.each do |key, val|
			if val.is_a? Array
				val.uniq!
				row[csv_array[key]] = val.join(", ")
			end
		end
		return row
	end

	def timeline_to_csv(args)
		rows 		= args[:rows]
		extension	= args[:extension] || 17280

		CSV.open("#{write_directory}/#{sheet.title}_#{extension}.csv", "wb") do |csv|
  			
  			#Write the csv headers
  			csv << ["Time", "Sentiment", "Preparation","Movement","Environment","Collective Information"]
  			
			timeline = []
			rows.times do |index|
				timeline << (Time.new(2012,10,22) + (index)*60) #It's rounded to the minute
			end

			#Create the rows
			timeline.each do |time|

				row_to_write = [time]

				if user_timeline.has_key? time
					add_values = vals_to_csv_array( user_timeline[time] )
					row_to_write += add_values
				end
				csv << row_to_write
			end
		end #Close the CSV
	end	
end