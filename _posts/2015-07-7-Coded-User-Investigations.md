---
layout: post
title:  "Movement Path Analysis for 97 Users"
date:   2015-07-07 13:00:00
permalink: /coded_users
js: ['leaflet.js', 'jquery-1.10.2.min.js','jquery-ui.js','coding-evacuators.js', 'd3.min.js', 'leaflet.SliderControl.min.js', 'leaflet.markercluster.js','moment.min.js', 'moment-timezone-with-data-2010-2020.min.js']
css: ['leaflet.css', 'MarkerCluster.Default.css','jquery-ui.css']
---

Click a username on the left to load their movement path into the map. Click on the map to make it interactive.  Move the slider across the top to see the path through time.  The tweets are in a table below. These are only geo-tagged tweets.

<h3>Current User: <span id='current_user'></span></h3>

<ul id="user_list" style="float:left;width:15%;list-style-type:none; margin:0; padding:0;height:600px;overflow:scroll;margin-top:30px;"></ul>

<div id="leaflet-slider"></div>
<div id="map" style="width:80%; height:600px;margin-left:5%;"></div>

<table id="tweet_texts"></table>

*Note that all of these times are LOCAL to New York City (with DST as well; ie either UTC-4 or UTC-5).
