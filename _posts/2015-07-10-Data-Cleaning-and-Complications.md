---
layout: full
title:  "Data Cleaning and Complications"
date:   2015-07-10 16:00:00
permalink: /data-complications
js: ['leaflet.js', 'jquery-1.10.2.min.js','jquery-ui.js','data-cleaning.js', 'd3.min.js', 'leaflet.SliderControl.min.js', 'leaflet.markercluster.js','moment.min.js', 'moment-timezone-with-data-2010-2020.min.js']
css: ['leaflet.css', 'MarkerCluster.Default.css','jquery-ui.css']
---


Keeping a log of lessons learned and complications that are being resolved:


#FourSquare

1. Frankenstorm check-ins.  Many users checked-in to the Frakenstorm Apocalypse event on FourSquare: 

		"text" : "I'm at Frankenstorm Apocalypse- Hurricane Sandy (New York, NY) w/ 287 others http://t.co/hlxfg1R6",
		"source" : "<a href=\"http://foursquare.com\" rel=\"nofollow\">foursquare</a>",
		"id_str" : "262592956303814657",
		"place" : {
			"country_code" : "US",
			"place_type" : "city",
			"full_name" : "Queens, NY",
			"name" : "Queens",
			"country" : "United States",
			"id" : "b6ea2e341ba4356f",
		"coordinates" : {
			"type" : "Point",
			"coordinates" : [
				-73.79179716,
				40.78953415
			]
		},
		"created_at" : ISODate("2012-10-28T16:33:34Z"),
		"user" : {
			"screen_name" : "BrittlynGleeson",
			"id_str" : "33439309",

Of the (unique) keyword collection, 1421 users checked into this event. This should be all of them because these tweets would show up in the keyword collection.

<!-- <script src="https://gist.github.com/jenningsanderson/d98878af76a1a023a049.js"></script> -->

<div id='frankenstorm_map' style="width:100%;height:600px;"></div>

2. In the keyword collection alone, there are 13,027 check-ins that are geo-tagged.  These are from 8,575 users. These are very valuable data points, but they also cannot be fully trusted when they represent very popular events.

