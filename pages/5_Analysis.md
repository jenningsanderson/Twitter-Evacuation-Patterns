---
layout: page
title: Analysis
permalink: /analysis/
---

After the data is coded according to the scheme outlined [here](../coding), the data is parsed and exported to a _csv_ file by ruby and then read by the statistics analysis tool R.

The following links go to the R output for visual timeline analysis.  It should open in a new window.

<ul>
	<li><a href="../analysis/r_timeline/user_timelines_relative_distances.html" target="_blank">Timeline with Relative Cluster Distances (0 - 20)</a></li>

<ul>

###How to read this output
The x-axis is time, beginning on the 22nd.

Starting from the top, each main category from the [coding scheme](../coding) has a row.  The coded behavior is then overlaid as text.

The _Geo Location_ row at the bottom tracks the user's actual movement between their location clusters (their contextual reported movement is the row above this).  Each row represents an arbitrary distance (normalized to [0,20]) between the clusters.  Therefore, consecutive dots on the same row mean each of the tweets were in the same location.  If consecutive dots go up or down rows between 0 and 20, then the user has moved to a new location.  The 20 line represents the mode (the cluster the user tweeted from the most during the event).

**Example**
Matt_Gunn's activity exists mostly between Geo Location 0 and 20, discretely.  Before the evacuation order and for a few hours after, he tweets from location 0 (his home).  However, at the same time he tweets that he's arrived to his evacuation location, we see the following tweets are all coming from GeoLocation 20, meaning they are the farthest away from previous location (0) compared to any of his other geotagged tweets.


####Key Static Dates:
1. The vertical dotted line represents 7pm on Sunday, October 28th.  The mayor ordered that Zone A be evacuated by this time.