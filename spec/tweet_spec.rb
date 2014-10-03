require 'spec_helper'

require_relative '../models/twitterer'

describe Tweet do

	before :all do 
		MongoMapper.connection = Mongo::Connection.new# (Local)
		MongoMapper.database = 'sandygeo'
	end

	it "Can get a user's first tweet and print it as geojson" do
		user = Twitterer.first

		pp user.tweets.first.as_geojson
	end
end