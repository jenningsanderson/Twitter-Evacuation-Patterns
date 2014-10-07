#
# Calculate Before Risk Level
#
# Using their best base location, as calculated with all of their tweets
#

require_relative '../config.rb'

#Write it out to a GeoJSON file
filename = "CalcualtedAffectedAreas"
include EpicGeo::Writers
boundaries_file = EpicGeo::Writers::GeoJSONWriter.new("../GeoJSON/exports/#{filename}")
boundaries_file.write_header

#Load these areas (Big to small)
risk_scores = {
	"../GeoJSON/NCAR_BoundingBox.GeoJSON"   => {risk: 50, name: "ncar"},
	"../GeoJSON/NYJ_Barrier_Coast.geojson" 	=> {risk: 20, name: "nj_barrier"},
	"../GeoJSON/NYC_ZoneC.geojson" 			=> {risk: 12, name: "ZoneC"},
	"../GeoJSON/NYC_ZoneB.geojson" 			=> {risk: 11, name: "ZoneB"},
	"../GeoJSON/NYC_ZoneA.geojson" 			=> {risk: 10, name: "ZoneA"}
}

bboxes = {}

risk_scores.each do |filepath, values|
	puts "Loading #{filepath}"
	bboxes[values[:name]] = {geometry: EpicGeo::Container::BoundingBox.new(geojson: filepath).geometry, risk_value: values[:risk]}
end

bboxes.each do |bbox, value|
	boundaries_file.write_feature(value[:geometry], {name: bbox})
end

boundaries_file.write_footer

#Search the Twitterer collection
results = Twitterer.find_each

results.each_with_index do |user, index|

	user.base_cluster_risk = 100 #Default

	base_point = user.base_cluster_point

	unless base_point.nil?
		bboxes.each do |name, values|
			if base_point.within? values[:geometry]
				user.base_cluster_risk = values[:risk_value]
			end
		end
	end

	user.flag = "before risk calculation 3"
	user.save

	if (index%100).zero?
		puts "----#{index}----"
	end
end