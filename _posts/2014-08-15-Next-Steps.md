---
layout: post
title:  "Next Steps"
date:   2014-08-15 20:15:00

---
<<<<<<< HEAD
<<<<<<< HEAD

#Next Steps

##Users with locations in known evacuation zones.
=======
=======

>>>>>>> master
##Identify Users with locations in known evacuation zones.
>>>>>>> master

####Affected Level
Previously, this bounding box was used:
[Original arbitrary bounding box](http://jenningsanderson.github.io/Twitter-Evacuation-Patterns/data/)

To keep things consistent, a different bounding box used with this dataset is defined here:
[NCAR bounding box](https://github.com/jenningsanderson/Twitter-Evacuation-Patterns/blob/master/GeoJSON/NCAR_BoundingBox.GeoJSON)

<<<<<<< HEAD
<<<<<<< HEAD
````
10 - Exist in the dataset
5  - Their userpath intersects NCAR bounding box
4  - Before location falls within NCAR bounding box
3  - Before location falls within an evacuation zone 'C'
2  - Before location falls within an evacuation zone 'B'
1  - Before location falls within an evacuation zone 'A'
````
=======
The user parameter ```affected_level``` is now defined as:
=======
There is a new parameter called ```path_affected``` which is either true or false.  If true, it means that at some point, the user's path intersected with the bounding box (always referring now to the new NCAR bounding box for consistency).

The user parameter ```affected_level_{before, during, after}``` is now defined as:

  - 100 - Default value (If all 3 are 100, then it implies that ```path_affected``` is false.)
  - 10  - Location falls WITHIN NCAR bounding box
  - 3  - Location falls WITHIN an evacuation zone 'C'
  - 2  - Location falls WITHIN an evacuation zone 'B'
  - 1  - Location falls WITHIN an evacuation zone 'A'

_Note: zones A,B,C are official terms found in the data for NYC.  Unsure if these will be consistent among other cities and states._
>>>>>>> master


<<<<<<< HEAD
_Note: zones A,B,C are official terms found in the data for NYC.  Unsure if these will be consistent among other cities and states._
>>>>>>> master
=======
###Current Steps
 1. Recut the bounding box to the NCAR box with the above parameters.
>>>>>>> master
