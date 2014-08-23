---
layout: post
title:  "Final Workflow"
date:   2014-08-20 12:13:00
---



##Initial Filters

####Foursquare
 1. Find relevant context in the Tweets


##Workflow
 1. Construct Twitterer Objects from the main collection of Tweets (Post filters)
 2. Analyze each Twitterer Object:
 	1. Run DBScan clustering algorithm on each User.
 	
 	
 	


###Determining Location during the event:

1. Find user clusters.  Do not limit the timespan anymore, simply find user clusters.
2. With each cluster, examine the following aspects:
   a. Tweeting Consistency?
   b. Holes in time for that cluster?
   
_Note: All clusters will have temporal holes in them.  What is important is to find the biggest clusters, since the dataset is so much bigger now._



###Determining Tweet Consistency
Using the same time blocking method as before, a ```T_Score``` is assigned to a cluster, this is now defined as 

	time blocks / number_of_tweets**2
	
