#Must determine the best geo methods for this part of the project.

#If we want to do the heavy lifting processing, what is the best tool? Probably geo_ruby?
#Could probably be using more Python, but I'm enjoying doing this in Ruby


#We should be more object oriented.  Here is an attempt to do so with Ruby
class Twitterer

	attr_accessor :handle, :id

	def initialize(id)
		@id = id
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
end
