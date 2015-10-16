#=Module for Handling the Full Contextual Stream, as it exists on Epic-Analytics
#
#
#
require 'json'
require 'time'
module ContextualStream

	#=Class to retrieve a full contextual stream
	class ContextualStreamRetriever

		attr_reader :root_path, :start_date, :end_date, :file_path, :in_stream, :handle

		def initialize(args)
			@root_path 	= args[:root_path]  || "/home/kena/geo_user_collection/"
			@start_date = args[:start_date] || Time.new(2010,01,01)
			@end_date   = args[:end_date]   || Time.new(2012,12,31)

			puts "Contextual Stream Retriever Initialized:"
			puts "\tBase Path:  #{root_path}"
			puts "\tStart Date: #{start_date}"
			puts "\tEnd Date:   #{end_date}"
		end

		def set_file_path(name)
			print "Looking for Stream: #{name}..."
			#Get the subcategory
			if name[0] =~ /[[:alpha:]]/
				alph = name[0].downcase
			else
				alph = 'non'
			end

			user = name.downcase

			@handle    = user
			@file_path = nil

			#Iterate through the root_path directory for the user's contextual file
			((1..6).to_a.map!{|num| "geo#{num}"} + ['ny_nj'] ).each do |section|
				test_path = "#{root_path}#{section}/user_data/#{alph}/#{user}-contextual.json"
				if File.exists? test_path
					@file_path = test_path
					break
				elsif File.exists? test_path+".bz2"
					unless File.exists? "/home/anderstj/tmp/#{user}-contextual.json"
						`cp #{test_path}.bz2 /home/anderstj/tmp/#{user}-contextual.json.bz2`
						`bunzip2 /home/anderstj/tmp/#{user}-contextual.json.bz2`
					end
					@file_path = "/home/anderstj/tmp/#{user}-contextual.json"
					break
				end
			end
			if file_path.nil?
				puts "Error, no stream exists for #{name}"
				return false
			else
				puts "found: #{file_path}"
				return true
			end
		end

		#Writing a wrapper to use bzip2 reader, if needed
		def open_file
			if file_path[-4..-1] == ".bz2"
				return Bzip2::Reader.open(file_path)
			else
				return File.open(file_path,'r')
			end
		end

		def get_user_id_str
			unless file_path.nil?
				tweet = JSON.parse(open_file.first.chomp)
				return tweet['user']['id_str']
			end
		end

		def get_user_join_date
			unless file_path.nil?
				tweet = JSON.parse(open_file.first.chomp)
				return tweet['user']['created_at']
			end
		end

		#Find the document on the server
		def get_full_stream(geo_only=false)
			tweets = [] # => To be returned
			unless file_path.nil?
				puts "Reading from: #{file_path}"
				#Now read the stream and return the Array
				begin
					tweet_count = 0
					geo_count = 0
					open_file.each do |line|
						tweet = JSON.parse(line.chomp)

						tweet_data = {}

						date = Time.parse(tweet["created_at"])

						if (date > start_date) and (date < end_date)

							tweet_count+=1

							tweet_data[:Date]   = date
							tweet_data[:Text]   = tweet["text"]
							tweet_data[:Id]     = tweet["id_str"]
							tweet_data[:Handle] = tweet["user"]["screen_name"]
							tweet_data[:Source] = tweet["source"]

							if tweet['coordinates']
								tweet_data[:Coordinates] = tweet['coordinates']['coordinates']
								geo_count += 1
								tweets << tweet_data
							else
								tweet_data[:Coordinates] = "------"
								unless geo_only
									tweets << tweet_data
								end
							end
			      end
					end
			    puts "--------Geo Ratio for #{handle}: #{geo_count} : #{tweet_count}---------\n"
			  rescue => e
		    	p $!
		    	puts e.backtrace
		    	puts "Stream may not have existed for: #{handle}"
			  end

				if tweets.length > 0
					return tweets
				else
					puts "No tweets!"
					return []
				end

			else
				puts "Error, unable to access the stream"
				return false
			end
		end
	end
end
