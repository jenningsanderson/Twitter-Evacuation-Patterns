# Tweet Model for TwitterGeo
#
# This Tweet extends TweetBase and provides geo self-awareness
#

require_relative 'TweetBase'

class Tweet < TweetBase

  include EpicGeo::GeoTweet

  #Keys for MM
  key :cluster,   Integer

  def post_initialize(args)
     point # => Force Tweet#point to be cast to a Point
  end

  #This is an over-ride for the current structure
  def date
  	@date
  end

end
