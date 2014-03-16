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

	def import_to_mongo(db_name)
		client = Mongo::MongoClient.new # defaults to localhost:27017
		db = client[db_name]
		coll = db['geo_tweets']
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

'''
Class for connecting to a local MongoDB
'''
class SandyMongoClient
	attr_reader :collection, :tweets, :tweets_for_plot
	attr_accessor :limit, :query

	def initialize(limit=nil)
		client = Mongo::MongoClient.new # defaults to localhost:27017
		db = client['sandygeo']
		@collection = db['tweets']
		@limit = limit
		@query = {}
	end

	def get_all()
		@collection.find({},{:limit=>@limit})
	end

	def get_tweets_for_plot(fields=nil)
		unless fields
			fields = ["geo.coordinates","text", "user.screen_name"]
		end
		@tweets_for_plot = Enumerator.new do |g|
			@collection.find(query,{:limit=>@limit, :fields=>fields}).each do |tweet|
				tweet_hash = {:text => tweet["text"], :coords => tweet["geo"]["coordinates"], :user_name => tweet["user"]["screen_name"]}
				g.yield tweet_hash
			end
		end
	end
end



def read_file_to_mongo(infile, mongo_db, max=nil, fields=nil)
	reader = Tweet_JSON_Reader.new(infile, max, fields)
	reader.import_to_mongo(mongo_db)
end

#Actual Runtime here
if __FILE__ == $0

	if ARGV[0] == '-mongo'
		puts "Running import to MongoDB"
		puts "File: #{ARGV[1]}, DB Name: #{ARGV[2]}"
		read_file_to_mongo(ARGV[1], ARGV[2])

	elsif ARGV[0] == '-writefrommongo'
		#Open the client
		mc = SandyMongoClient.new(limit=200000)

		#Create the shapefile
		tweet_shape = Tweet_Shapefile.new('two_hundred_k_sandy_tweets')
		tweet_shape.create_point_shapefile

		#Iterate through the tweets
		mc.get_tweets_for_plot

		counter = 0
		mc.tweets_for_plot.each do |tweet|
			tweet_shape.add_point(tweet)
				counter += 1
			if counter %10000==0
				puts counter
			end
		end
	end
end
