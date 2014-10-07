#
# Process the NCAR bounding box
# => If a user doesn't already have a before_risk_level, then check if they're in the box
# => 

require_relative '../config.rb'

#Areas
risk_scores = {
	"../GeoJSON/NCAR_BoundingBox.geojson" 	=> 50
}

risk_scores.each do |filepath, risk_value|
	
	#bbox.geometry is the geometry of the bounding box
	bbox = EpicGeo::Container::BoundingBox.new(geojson: filepath)

	#Search the Twitterer collection
	results = Twitterer.find_each(:base_cluster_risk => nil)

	results.each_with_index do |user, index|

		base_point = user.base_cluster_point

		unless base_point.nil?
			if base_point.within? bbox.geometry
				user.base_cluster_risk = risk_value
			else
				user.base_cluster_risk = 100 #Implies they're out of the area
			end
		end

		user.flag = "before risk calculation 2"
		user.save

		if (index%100).zero?
			puts "----#{index}----"
		end
	end
end

