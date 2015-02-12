---
layout: map
title:  "Mapping Qualitative Data"
date:   2014-12-01 11:00:00
permalink: /mapanalysis
---

#Mapping Our Qualitative Data

<div id="user_list" style="float: left; width:14%; text-align:left">
<ul style="list-style-type:none;">
{% for user in site.data.qualmaps %}
	<li><a href="{{site.baseurl}}/mapanalysis?user={{ user[0] }}">{{user[0]}}</a></li>
{% endfor %}
</ul>
</div>

<!-- <nav id='filters' class='filter-ui'></nav> -->
<script src="{{site.baseurl}}/assets/js/qualitative_map.js">