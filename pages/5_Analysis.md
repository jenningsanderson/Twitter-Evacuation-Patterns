---
layout: page
title: Analysis
permalink: /analysis/
---

After the data is coded according to the scheme outlined [here](../coding), the data is parsed and exported to a _csv_ file by ruby and then read by the statistics analysis tool R.

The following links go to the R output for visual timeline analysis.  It should open in a new window.

<a href="../analysis/r_timeline/user_timelines_relative_distances.html" target="_blank">Timeline with Relative Cluster Distances (0 - 20)</a>

###How to read this output
The x-axis is time, beginning on the 22nd.

Starting from the top, each main category from the [coding scheme](../coding) has a row.  The coded behavior is then overlaid as text.

The _Geo Location_ row at the bottom tracks the user's actual movement between their location clusters (their contextual reported movement is the row above this).  Each row represents an arbitrary distance (normalized to [0,20]) between the clusters.  Therefore, consecutive dots on the same row mean each of the tweets were in the same location.  If consecutive dots go up or down rows between 0 and 20, then the user has moved to a new location.  The 0 line represents the mode (the cluster the user tweeted from the most during the event).


####Key Static Dates:
1. The vertical dotted line represents 7pm on Sunday, October 28th.  The mayor ordered that Zone A be evacuated by this time.