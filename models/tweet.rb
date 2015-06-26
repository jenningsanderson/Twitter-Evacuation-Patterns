#A Tweet Object.
#
#
#
class Tweet
  #Used for DBScan Clustering
  attr_accessor :cluster, :visited

  include Mongoid::Document
  embedded_in :Twitterer

  #Make the Tweet GeoAware
  include EpicGeo::GeoTweet

  #Variables to be saved to Mongo
  field :id_str, 			type: String
  field :text, 				type: String
  field :user, 				type: String
  field :handle, 			type: String
  field :date, 				type: Time
  field :coordinates, type: Array
  field :cluster,     type: Integer
  field :contextual,  type: Boolean

  #Can add more coding information here, if desired

  #Corrects for the time zone // do we want to do this?
  # def date
  #   @date.getlocal(-6*3600)
  # end

  #Return the tweet as a hash in valid geojson for storing as a complete feature in a GeoJSON file.
  def as_geojson
    {:type=>"Feature", :properties=>{:time=>date.iso8601, :text=>text}, :geometry=>coordinates}
  end
end
