---
layout: post
title:  "A New Algorithm"
date:   2014-08-22 12:13:00
---

###Adapting to first round of Qualitative Analysis
The first round of qualitative analysis showed that the triangle analysis method's use of exact dates for "before", "during", and "after" did not capture individual behavior as well.  Perhaps this should not be surprising as it may not be prudent to reduce each user's behavior to just three points.

####Issues with Previous Method

 1. Users were far too dynamic in their time bins. Static time bins could not capture it.
 2. Evacuations are not as clear cut as originally hoped.  Some users did not return home immediately, this is probably  the result of the power outages along the Eastern Seaboard.
 
As such, a new approach is required that allows for more dynamic, flexible time bins per user.  The new approach is different in the following ways:

 - Uses Tweets from October 1, 2012 to December 31, 2012
 - Builds _home_ or _shelter_ location by looking at all tweets, not just those within a specific time bin.
 - Looks at patterns overtime, not just within a specific time window.
 

###New Method:
####Clusters
First, the DBScan algorithm is run on all of a user's points to determine all of the locations where a user has a cluster of tweets.  The parameters at this point are: ```DBScanCluster.new(tweets, epsilon=25, min_pts=2)```
 Clusters therefore must have a radius of 25meters and the minimum number of points in a cluster is 2.
 
####Temporal Regularity Analysis
Similar to the previous method, each cluster is given a ```T_score``` This is defined as the following block of code (Also, see the Design page for a better description of this temporal regularity grouping step)

````
times = tweets.collect{|tweet| tweet["date"]}
	blocks = []
	times.each do |time|
		blocks << time.hour/3
	end
	blocks.group_by{|value| value}.keys.length / times.length**2.to_f
````

####Finding the Gap
Imagine reducing a user's location each day to the following array of cluster IDs:
```[1,1,1,1,1,1,1,2,2,2,1,1,1]```
Where 1,2 are the IDs of clusters with very low T_scores (lower is better).  This implies that a user tweeted for 5 days in a row from cluster 1, followed by 3 days of not tweeting from cluster 1 and only from cluster 2, and then resumed tweeting from cluster 1 for the following 5 days.  If we know that this 12 day period falls between October 24 and November 4, then there is a decent chance that this user left location 1 during the storm and returned after.

Furthermore, if we look at all of a user's tweets between October 1 - 25 to identify their most regularly tweeted from cluster and determine that to be ```cluster 1```, then we may claim that cluster 1 is most likely the location of their home or common shelter and that they left and came back to it.

This user would then be listed as exhibiting potential evacuation behavior and be marked for further qualitative analysis.

#####Additional Benefits
 1. It is not always the case the user only goes one place, so this method has the ability to implement accounting for this.