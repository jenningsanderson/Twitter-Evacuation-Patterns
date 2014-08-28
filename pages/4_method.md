---
layout: page
title: Method
permalink: /Method/
---

The time period of interest is October 21 to November 9, 2012. Imperical evidence shows that most or all potential evacuation behavior is or would be exhibited during this time period.

First, these dates are converted to the day of the year for simplicity and grouping by day:

	2012-10-21 => 295
	2012-10-22 => 296
	2012-10-23 => 297
	2012-10-24 => 298
	2012-10-25 => 299
	2012-10-26 => 300
	2012-10-27 => 301
	2012-10-28 => 302
	2012-10-29 => 303
	2012-10-30 => 304
	2012-10-31 => 305
	2012-11-01 => 306
	2012-11-02 => 307
	2012-11-03 => 308
	2012-11-04 => 309
	2012-11-05 => 310
	2012-11-06 => 311
	2012-11-07 => 312
	2012-11-08 => 313
	2012-11-09 => 314

Next, we group a user's tweets by cluster by day, for example:

	300 => ["0"]
	302 => ["1"]
	303 => ["1"]
	304 => ["1"]
	305 => ["1"]
	306 => ["0", "1", "3"]
	307 => ["0"]
	311 => ["3"]
	312 => ["4"]
	314 => ["0", "4"]
	
