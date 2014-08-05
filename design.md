---
layout: page
title: Design
permalink: /design/
---

#User Shelter

The main design of this work is to identify where a user took shelter at various times during Hurricane Sandy


###Step 1. Establish Time Bins for the event: 

Before | During | After
:-----:| :-----:| :----:
October 22 - 28 | October 28 - Nov 1 | November 1 - December 7 |


###Step 2. Identify spatial clusters

![DBScan Example]({{site.baseurl}}/img_exports/DB_Scan_GoogleEarth.png "DB Scan Example")

The [DBScan algorithm](http://en.wikipedia.org/wiki/DBSCAN) is used here for density based clustering.  Tweets are clustered by geospatial density.

Each cluster is then analyzed for relative density:

```Density``` = 2<sup>(number of tweets)</sup> /  (area of convex hull around tweets)

###Step 3. Identify Temporal Spread

Dividing a 24 hour day into 8 separate time bins of 3 hours, the goal here is to find repetitive behavior.

Imagine two clusters of tweets: X and O:

| Hour | Day 1 | Day 2 | Day 3 | Day 4 | Day 5 | Day 6 | Day 7 |
|:------ |:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
1 |  X   |  X    |  X    |  X    |  X    |   X   |   X   |   X   |  X    |
2 |      |       |       |       |       |       |       |       |       |
3 |      |       |       |       |       |       |       |       |  O    |
4 |  O   |       |       |       |       |   O   |       |       |       |
5 |      |       |  O    |       |  O    |       |       |    O  |       |
6 |      |  O    |       |       |       |       |   O   |       |       |
7 |      |       |       |  O    |       |       |       |       |       |
8 |      |       |       |       |       |       |       |       |       |

In this 7 day window, Each cluster of tweets had exactly 7 tweets, once per day.  However, the temporal spread of the X tweets is only 1, meaning that each day the user tweeted from within the same 3 hour window.

The O tweets, however, have a temporal spread of 5, meaning that these 7 tweets in this cluster happened sporadically over 21 hours of the day.

The ultimate calculation formula is: 

````Tweets / Area / Time Spread````


```Time Clusters``` = Value between 1 and 8: Number of blocks of 3 hours in which the tweets in that cluster occur.  (A measure of deviation within the hours of the day when a user tweets)

```Weighted Location``` = The median location of the cluster which maximizes ```Density/Time Clusters```

This weighted location is then set as the 'before', 'during', or 'after' location of a user with reference to where they were during that time.

![Before During After]({{site.baseurl}}/img_exports/BeforeDuringAfter.png "Three POIs")
