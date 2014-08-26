---
layout: post
title:  "New Data Structure""
date:   2014-08-25 1:45:00
---




##Twitterer
The Twitterer model has the following attributes and metrics.  Model Functions are available in the documentation

###Filtering Attributes
These attributes are indexed to make intelligent queries.  All geo-relevant queries should only look at users where ```path_affected == true```.  Queries to determine evacuation behavior should further filter for ```shelter_in_place == false```

####Basic Filtering Attributes
| Variable					| Type		| Description |
|--------------------------------------------------|
| ```unclassifiable```	| Boolean | At some point, the method has deemed this user as unclassifiable due to a lack of information _**Update**: Users with no affected path are also considered unclassifiable currently_ |
| ```path_affected```	| Boolean | Whether or not this user's path intersects with the bounding box |
| ```shelter_in_place```	| Boolean | If the method has determined at any point the user sheltered in place, then this value is set to true |
| ```unclassified_percentage``` | Integer | A rounded integer [0,100], that describes the percentage of the user's tweets that did not land in a cluster during the DBScan clustering.



####Advanced Filtering Attributes

```hazard_level_before```:
A ranking variable for a user's calculated pre-storm home/shelter location that decreases as their level of potential danger / storm affectedness increases.

| Value			| Description |
|----------------------------------------|
|10| The user's before home/shelter location exists in ** NYC Evacuation Zone A ** |
|20| The user's before home/shelter location exists in ** NYC Evacuation Zone B ** |
|30| The user's before home/shelter location exists in ** NYC Evacuation Zone C ** |
|  |
|50| The user's before home/shelter location exists within the Bounding Box |
|  |
|100| The user's before home/shelter location does not fall within the bounding box, however, their full movement path between tweets does intersect with the bounding box.  (Could be a user traveling through NYC)


###Movement Variables

| Variable | Type | Description |
|----------------------------------------|
| ```shelter_in_place_location``` | Array | If a user sheltered in place, then this is the location that was calculated for that |
| ```during_storm_movement``` | 2D Array | The x,y points of the user's during storm movement |
|```cluster_movement_pattern```| Array | A list of cluster IDs, including the before and after the storm. ** Example: ** ```["1","1","2","2","1"]``` implies that a user's before and after storm location are calculated as cluster ID "1" and during the storm they moved from cluster 1 to cluster 2, but did not return to cluster 1 in the during storm window.


###Stored Location Attributes
| Variable | Type | Description |
|-------------------------------|
|```cluster_locations``` | Hash | Key : Value pair of Cluster ID : ```[x,y]```.  If available, ```:before_home``` and ```:after_home``` are keys |



###Basic Attributes

|Variable | Type | Description |
|------------------------------|
|```handle```   | String | User's screen name.  If they had more than one screen name, then it appears as a comma separated list, but still a string.
|```tweet_count``` | Integer | The number of tweets embedded in the user document |
|```id_str```	| String | User's id_str attribute from Twitter |


###Sample User Document:

	"_id" : ObjectId("53f61f802ddc1832ce001021"),
	"id_str" : "256002542",
	"handle" : "Alexandroh82",
	"tweet_count" : 146,
	"issue" : 40,
	"during_storm_movement" : [
		[
			-74.005592,
			40.78649
		],
		[
			-74.00619055,
			40.7886864
		]
	],
	"cluster_locations" : {
		"before_home" : [
			-74.00619055,
			40.7886864
		],
		"after_home" : [
			-74.00619055,
			40.7886864
		],
		"8" : [
			-74.00619055,
			40.7886864
		],
		"10" : [
			-74.005592,
			40.78649
		]
	},
	"cluster_movement_pattern" : [
		"8",
		"10",
		"8",
		"8"
	],
	"hazard_level_before" : 50,
	"shelter_in_place" : false,
	"shelter_in_place_location" : [ ],
	"confidence" : 40,
	"unclassified_percentage" : 60,
	"path_affected" : true,
	"before" : [ ],
	"during" : [ ],
	"after" : [ ]

