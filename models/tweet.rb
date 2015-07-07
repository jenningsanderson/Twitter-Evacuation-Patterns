#A Tweet Object.
#
#
#
class Tweet

  include Mongoid::Document
  embedded_in :Twitterer

  #Make the Tweet GeoAware
  include EpicGeo::GeoTweet

  #Used for DBScan Clustering
  attr_accessor :cluster, :visited

  #Variables to be saved to Mongo
  field :id_str, 			type: String
  field :text, 				type: String
  field :user, 				type: String
  field :handle, 			type: String
  field :date, 				type: Time
  field :coordinates, type: Array
  field :cluster_id,  type: String
  field :contextual,  type: Boolean

  def id
    return id_str
  end

  def utc_date
    date.utc
  end

  def local_date
    if date.dst?
      date.getlocal(-4*3600)
    else
      date.getlocal(-5*3600)
    end
  end

end
