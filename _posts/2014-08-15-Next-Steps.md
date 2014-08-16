---
layout: post
title:  "Next Steps"
date:   2014-08-15 20:15:00
---
##Identify Users with locations in known evacuation zones.

####Affected Level
Previously, this bounding box was used:
[Original arbitrary bounding box](http://jenningsanderson.github.io/Twitter-Evacuation-Patterns/data/)

To keep things consistent, a different bounding box used with this dataset is defined here:
[NCAR bounding box](https://github.com/jenningsanderson/Twitter-Evacuation-Patterns/blob/master/GeoJSON/NCAR_BoundingBox.GeoJSON)

The user parameter ```affected_level``` is now defined as:

  - 10 - Exist in the dataset
  - 5  - Their userpath intersects NCAR bounding box
  - 4  - Before location falls within NCAR bounding box
  - 3  - Before location falls within an evacuation zone 'C'
  - 2  - Before location falls within an evacuation zone 'B'
  - 1  - Before location falls within an evacuation zone 'A'

_Note: zones A,B,C are official terms found in the data for NYC.  Unsure if these will be consistent among other cities and states._