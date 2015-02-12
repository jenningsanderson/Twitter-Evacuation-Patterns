---
layout: map_simple
title:  "Geographical Distribution of Tweets & Users"
date:   2015-02-11 17:00:00
permalink: "/geodistribution"
---

## Geo Distribution of Users

Each marker represents a single user's "base cluster" location, based on their Twitter habits up to the storm.

<div id="map" style="height:600px; width: 100%;"></div>
<script type="text/javascript">

$(document).ready(function(){

	// add an OpenStreetMap tile layer
	var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
		attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
	});

	var map = L.map('map', {zoom: 6, center: [37.788,-77.102]});

	tiles.addTo(map)

	var high_risk = new L.MarkerClusterGroup();
	var low_risk = new L.MarkerClusterGroup();
	//var markers = new L.MarkerClusterGroup();

	//Layers
	var most_affected = new L.GeoJSON.AJAX("/Twitter-Evacuation-Patterns/datasets/geo_distribution/most_affected_users.geojson", {onEachFeature:
			function(feature, layer){
				layer.bindPopup("Handle: "+feature.properties.handle);
				high_risk.addLayer(layer)}
			});

	var less_affected = new L.GeoJSON.AJAX("/Twitter-Evacuation-Patterns/datasets/geo_distribution/less_affected_users.geojson", {onEachFeature:
			function(feature, layer){
				layer.bindPopup("Handle: "+feature.properties.handle);
				low_risk.addLayer(layer)}
			});

	high_risk.addTo(map)
	low_risk.addTo(map)



	var overlays = {
	    "Users at High Risk" : high_risk,
	    "Users at Lower Risk" : low_risk
	};

	L.control.layers(null, overlays).addTo(map)
	
});
</script>

<br>

##Download

5979 "Most affected users" (by risk of location: coastline): [GeoJSON]({{site.baseurl}}/datasets/geo_distribution/most_affected_users.geojson)

14338 "Less affected users" (by risk of location: not coastline): [GeoJSON]({{site.baseurl}}/datasets/geo_distribution/less_affected_users.geojson)