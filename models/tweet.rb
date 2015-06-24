#A Tweet Object.
#
#
#
class Tweet
  #Used for DBScan Clustering
  attr_accessor :cluster, :visited

  #Extend the MongoMapper EmbeddedDocument
  include MongoMapper::EmbeddedDocument

  #Make the Tweet GeoAware
  include EpicGeo::GeoTweet

  #Variables to be saved to Mongo
  key :id_str, 			String
  key :text, 				String
  key :user, 				String
  key :handle, 			String
  key :date, 				Time
  key :coordinates, Array
  key :cluster,     Integer
  key :contextual,  Boolean

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
