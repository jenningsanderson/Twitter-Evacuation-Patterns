---
layout: page
title: Design
permalink: /design/
---

#User Shelter

The main design of this work is to identify where a user took shelter at various times during Hurricane Sandy.  From these points of interest, a Twitterers's movement pattern during the hurricane can be analyzed to determine protective decisions they may (or may not) have made about their shelters.


###Step 1. Establish Time Bins for the event:

Before | During | After
:-----:| :-----:| :----:
October 22 - 28 | October 28 - Nov 1 | November 1 - November 7 |


###Step 2. Identify spatial clusters

![DBScan Example]({{site.baseurl}}/img_exports/DB_Scan_GoogleEarth.png "DB Scan Example")

The [DBScan algorithm](http://en.wikipedia.org/wiki/DBSCAN) is used here for density based clustering.  Tweets are clustered by geospatial density.  Benefits of this method include:

1. Not necessary to define #clusters before hand (Like k-means).
2. Includes a non-cluster group which can be thrown out.

Each cluster is then analyzed for _relative density_:

The number of tweets is very important and will be washed out by the relative size of the area (square meters).  Therefore, a Tweet Variable is defined as: _2<sup>(number of tweets)</sup>_ to heavily weight the number of tweets.

The area of the tweet cluster is defined as the area of the convex hull constructed from the points in the cluster.


The tweet density is then defined as:
````(Tweet Variable) / (Area of convex hull)````

###Step 3. Identify Temporal Spread
We must determine a user's repetitive tweeting behavior to get the best idea of when and where they tweet.  Empirical analysis and speaking with lead Geo-HCI researcher, [Brent Hecht](http://www.brenthecht.com/), shows that people generally seem to show repetitive tweet behavior at a given location.  For example, watching television at home at night.

Dividing a 24 hour day into 8 separate time bins of 3 hours, the goal is to find repetitive temporal behavior.

####Example:
Imagine two clusters of tweets: X and O:

|Hour | Day 1 | Day 2 | Day 3 | Day 4 | Day 5 | Day 6 | Day 7 | Day 8 | Day 9 |
|:--- |:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
|1    |  X    |  X    |  X    |  X    |  X    |   X   |   X   |   X   |  X    |
|2    |       |       |       |       |       |       |       |       |       |
|3    |       |       |       |       |       |       |       |       |  O    |
|4    |  O    |       |       |       |       |   O   |       |       |       |
|5    |       |       |  O    |       |  O    |       |       |    O  |       |
|6    |       |  O    |       |       |       |       |   O   |       |       |
|7    |       |       |       |  O    |       |       |       |       |       |
|8    |       |       |       |       |       |       |       |       |       |

In this 9 day window, Each cluster of tweets had exactly 9 tweets, once per day.  However, the temporal spread of the X tweets is only 1, meaning that each day the user tweeted from within the same 3 hour window.

The O tweets, however, have a temporal spread of 5, meaning that the 9 tweets in this cluster occurred sporadically over 21 hours of the day, each day.

The units turn out to be:

````Tweet Count Variable / Area / Time Spread````


```Weighted Location``` = The median location of the cluster which maximizes  the above formula.

This weighted location is then set as the 'before', 'during', or 'after' location of a user with reference to the time bin that included these tweets.


#####Visual Example:

![Part 1]({{site.baseurl}}/img_exports/poi_example_part1.png "Overview of POIs")

![Part 2]({{site.baseurl}}/img_exports/poi_example_part2.png "During, After Expanded")
