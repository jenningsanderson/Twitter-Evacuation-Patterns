---
layout: post
title:  "New Filters Applied to Twitterers"
date:   2014-08-04 09:30:00
---

#New Filters

	1. Users must have at least 15 tweets total.
	2. Their 'before' point must fall within an area of significant interest.
	3. Perhaps 5,5,5 tweets must exist in each bin for 'before', 'during', and 'after'

## Summary Statistics

	1. Users with >= 15 tweets total: 20,317
		(This is the entire Twitterers Collection)
	2. Users with >= 5 Tweets in before/during/after: 15,020
	3. Users with 'before' location in a point of interest


````
[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20].forEach(function(limit){print(users.count({$and : [{before_tweet_count : {$gte : limit}},{during_tweet_count : {$gte : limit}},{after_tweet_count : {$gte : limit}}]}))})
````


##TODO
1. Rerun the clustering algorithm and give each user a better location based on dbscan (not the previous k-means density count)

2. Define threshold and remove tweets?

3. Determine measure of accuracy for the location?
