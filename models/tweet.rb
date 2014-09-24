# Tweet Model for TwitterGeo
#
# This Tweet extends TweetBase and provides geo self-awareness
#

require 'rgeo'
require 'georuby' #This will be updated soon

require_relative 'TweetBase'

class Tweet < TweetBase

  #A Tweet can be accessed as an RGEO point object as tweet.point
  @@geo_factory = RGeo::Geographic.simple_mercator_factory #Is this best practice?

  #Used for DBScan Clustering
  attr_accessor :cluster, :visited

  def post_initialize(args)
    point # => Force Tweet#point to be cast to a Point
  end

  #In order to call the Tweet#point instance, it must be defined
  def point
    #Return point or define and then return point
    @point ||= @@geo_factory.point(
          @coordinates["coordinates"][0],
          @coordinates["coordinates"][1])
  end

  #To write the tweet to a kml file from epic-geo,
  # it must be formatted as follows:
  def as_epic_kml(style=nil)
    {:time     => @date,
     :style    => style,
     :geometry => GeoRuby::SimpleFeatures::Point.from_x_y(
       @coordinates["coordinates"][0],
       @coordinates["coordinates"][1] ),
     :name     => nil, #Setting name to nil because otherwise it's hard to see
     :desc     =>
     %Q{#{@handle}<br />
        #{@text}<br />
        #{@date}}
    }
  end

  #Return this tweet as valid GeoJSON
  def as_geojson
    {:type=>"Feature",
     :properties=>{ :Time=>date,
                    :text=>text,
                    :handle=>handle},
     :geometry=>coordinates}
  end
end
