#
# Calculate Before Risk Level
#
# Using their best base location, as calculated with all of their tweets
#

require_relative '../config.rb'

#Areas
risk_scores = {
	"../GeoJSON/NYJ_Barrier_Coast.geojson" 	=> 20,
	"../GeoJSON/NYC_ZoneA.geojson" 			=> 10,
	"../GeoJSON/NYC_ZoneB.geojson" 			=> 11,
	"../GeoJSON/NYC_ZoneC.geojson" 			=> 12
}

risk_scores.each do |filepath, risk_value|
	
	#bbox.geometry is the geometry of the bounding box
	bbox = EpicGeo::Container::BoundingBox.new(geojson: filepath)

	#Search the Twitterer collection
	results = Twitterer.find_each

	results.each_with_index do |user, index|

		base_point = user.base_cluster_point

		unless base_point.nil?
			if base_point.within? bbox.geometry
				user.base_cluster_risk = risk_value
			end
		else
			user.unclassifiable = true
		end
		user.flag = "before risk calculation 2"
		user.save

		if (index%100).zero?
			puts "----#{index}----"
		end
	end
end