---
layout: post
title:  "Next Steps"
date:   2014-08-15 20:15:00
---

#Next Steps

##Users with locations in known evacuation zones.

####Affected Level
Previously, this bounding box was used:
[Original arbitrary bounding box](http://jenningsanderson.github.io/Twitter-Evacuation-Patterns/data/)

To keep things consistent, a different bounding box used with this dataset is defined here:
[NCAR bounding box](https://github.com/jenningsanderson/Twitter-Evacuation-Patterns/blob/master/GeoJSON/NCAR_BoundingBox.GeoJSON)

````
10 - Exist in the dataset
5  - Their userpath intersects NCAR bounding box
4  - Before location falls within NCAR bounding box
3  - Before location falls within an evacuation zone 'C'
2  - Before location falls within an evacuation zone 'B'
1  - Before location falls within an evacuation zone 'A'
````
