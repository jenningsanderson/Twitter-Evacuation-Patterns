'''This script reformats the BSON date in Mongo to an actual date for queries...'''

require '../tweet_io'
require 'bson'
require 'date'
require 'time'



if __FILE__ == $0
  #Connect to Mongo
  conn = SandyMongoClient.new

  conn.get_all.each do |tweet|
    unless tweet["created_at"].is_a? Time
      id        = tweet["_id"]
      datestamp = DateTime.parse(tweet["created_at"]).to_s
      timestamp = Time.parse(datestamp).utc
      conn.collection.update({"_id" => id },{"$set" => {"created_at" => timestamp}})
    end
  end
end
