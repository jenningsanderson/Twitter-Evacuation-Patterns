#Must determine the best geo methods for this part of the project.

#If we want to do the heavy lifting processing, what is the best tool? Probably geo_ruby?
#Could probably be using more Python, but I'm enjoying doing this in Ruby


#We should be more object oriented.  Here is an attempt to do so with Ruby
class Twitterer
	attr_accessor :handle, :id
	attr_reader :tweets

	def initialize(id)
		@id = id
		@tweets = []
	end 

	def add_tweet(bson_tweet)
		@tweets << Tweet.new(bson_tweet)
	end

	#This function returns each tweet as a point
	def individual_points(with_tweets=false)
		return false

		#If we want tweet text as well, then return that.
		if with_tweets
			return false
		end
	end

	#This function will return a linestring of their tweet locations
	def full_user_path
		return false
	end

	def to_hash
    Hash[instance_variables.map { |var| [var[1..-1].to_sym,instance_variable_get(var)] }]
  end
end

class Tweet
	attr_accessor :text, :id, :date, :loc
	def initialize(bson_tweet)
		@id     = bson_tweet["id"]
		@text   = bson_tweet["text"]
		@user   = bson_tweet["user"]["id_str"]
		@handle = bson_tweet["user"]["screen_name"]
		@date   = bson_tweet["created_at"]
		@loc    = bson_tweet["coordinates"]
	end
end
