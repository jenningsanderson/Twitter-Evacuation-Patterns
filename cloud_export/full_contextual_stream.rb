# Class for handling a user's full contextual stream

require 'time'

class FullContextualStreamRetriever

	def initialize(root_path, start_date, end_date)
		@root_path = root_path
		@start_date = start_date || Time.new(2012,07,01) #These are just defaults
		@end_date   = end_date   || Time.new(2012,12,31)

		puts "Contextual Stream Retriever Initialized:"
		puts "\tBase Path: #{@root_path}"
		puts "\tStart Date: #{@start_date}"
		puts "\tEnd Date: #{@end_date}"

	end

	#Find the document on the server
	def get_full_stream(name)
		puts "Looking for Stream: #{name}"

		tweets = [] # => To be returned

		#Get the subcategory
		if name[0] =~ /[[:alpha:]]/
			alph = name[0].downcase
		else
			alph = 'non'
		end

		user = name.downcase

		file_path = nil
		in_stream = nil

		#Iterate through the root_path directory for the user's contextual file
		(1..6).to_a.map!{|num| "geo#{num}"}.each do |section|
			test_path = "#{@root_path}#{section}/user_data/#{alph}/#{user}-contextual.json"
			if File.exists? test_path
				file_path = test_path
				in_stream  = File.open(file_path,'r')
				break
			end
		end

		unless file_path.nil?
			puts "Found the path, now reading from: #{file_path}"

			#Now read the stream and return the Array
			begin
				tweet_count = 0
				geo_count = 0
				in_stream.each do |line|
					tweet = JSON.parse(line.chomp)

					tweet_data = {}

					date = Time.parse(tweet["created_at"])
					
					if (date > @start_date) and (date < @end_date)
		        	
						tweet_count+=1
						
						tweet_data[:Date] = date
						tweet_data[:Text] = tweet["text"]

						if tweet['coordinates']
							tweet_data[:Coordinates] = tweet['coordinates']['coordinates']
							geo_count += 1
						else
							tweet_data[:Coordinates] = "------"
						end

						tweets << tweet_data
		          	end
				end
		    	puts "--------Geo Ratio for #{user}: #{geo_count} : #{tweet_count}---------\n"
		    rescue => e
		    	p $!
		    	puts e.backtrace
		    	puts "Stream may not have existed for: #{user}"
		    end
		    if tweets.length > 0
				return tweets
			else
				puts "No tweets!"
			end
		else
			puts "Error, unable to find the stream"
			return false
		end
	end
end
