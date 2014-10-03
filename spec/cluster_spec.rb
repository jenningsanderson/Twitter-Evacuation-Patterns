require 'spec_helper'

require_relative '../models/twitterer'

describe Twitterer do

	before :all do 
		MongoMapper.connection = Mongo::Connection.new# (Local)
		MongoMapper.database = 'sandygeo'
	end

	it "Can run a dbscan clustering algorithm on a user's tweets" do
		user = Twitterer.where(handle: "iKhoiBui").first
	
		clusterer = EpicGeo::Clustering::DBScan.new(user.tweets, epsilon=50, min_pts=2)
		clusters = clusterer.run
		
		expect clusters.keys.length > 0
	end

	
end