require 'rgeo-shapefile'
require 'geo_ruby'
require 'geo_ruby/shp'
require 'json'
require 'mongo'
require 'pp'

'''
Class for handling the a big tweet file from EPIC.
'''
class Tweet_JSON_Reader
	attr_reader :json_filename, :tweets

	# Pass in the file (json tweet per line), and a potential max line arg
	def initialize( in_file, max=nil, fields=nil)
			@json_filename = in_file

		unless max.nil?
			@tweets_file = File.open(@json_filename).first(max).each
		else
			@tweets_file = File.open(@json_filename).each
		end

		set_fields(fields)

		#Define an enumerator
		@tweets = Enumerator.new do |g|
			@tweets_file.each do |line|
				tweet = JSON.parse(line.chomp)
				g.yield extract_tweet(tweet)
			end
		end
	end

	def set_fields(interested_fields)
		unless interested_fields
			@fields = {
				:coords => '["geo"]["coordinates"]',
				:text   => '["text"]',
				:user_name => '["user"]["screen_name"]'
			}
		end
	end

	def extract_tweet(tweet_json)
		tweet = Hash.new
		@fields.each do |k,v|
			tweet[k] = instance_eval "#{tweet_json}#{v}"
		end
		return tweet
	end

	def get_tweet
		tweet = JSON.parse(@tweets_file.next.chomp)
		@fields.each do |k,v|
			this_tweet[k] = instance_eval "#{tweet}#{v}"
		end
		return this_tweet
	end

	def import_to_mongo
		client = Mongo::MongoClient.new # defaults to localhost:27017
		db = client['sandy']
		coll = db['tweets']
		counter = 0
		@tweets_file.each do |line|
			tweet = JSON.parse(line.chomp)
			coll.insert(tweet)
			counter += 1
			if counter % 10000 == 0
				puts counter
			end
		end
	end
end


class SandyMongoClient
	attr_reader @tweets

	def initilialize
		client = Mongo::MongoClient.new # defaults to localhost:27017
		db = client['sandy']
		@tweets = db['tweets']
	end

	def
		@tweets = Enumerator.new do |g|
			@tweets_file.each do |line|
				tweet = JSON.parse(line.chomp)
				g.yield extract_tweet(tweet)
			end
		end

	end
end
