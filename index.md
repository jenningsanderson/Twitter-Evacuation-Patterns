---
layout: default
---

<script src="https://gist.github.com/jenningsanderson/574b51634bcc0d615449.js"></script>


<div class="home">
  <h1>Identifying Protective Decision Making Behavior through GeoLocated Tweets</h1>
  <p>The goal of this project is to identify potential evacuation behavior based on geotags and timestamps within a Twitterer's contextual stream (EPIC).
  </p>

  <p>This project is a continuation of work previously done with Andrew Hardin and Ellie Falletta in CU Geography 5303 (Spring 2014)</p>

  <br>
  <hr>


  <h1>Top Pages</h1>

  <ul class="posts">
  		<li><a class="post-link" href="{{site.baseurl}}/Statistics">Latest Statistics</a></li>
		<li><a class="post-link" href="{{site.baseurl}}/weaknesses">Known Weaknesses</a></li>
  </ul>



  <h1>Full Contents</h1>

   <ul class="posts">
     {% for post in site.posts %}
       <li>
         <span class="post-date">{{ post.date | date: "%b %-d, %Y" }}</span>
         <a class="post-link" href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
       </li>
     {% endfor %}
   </ul>

  <br>
  <hr>
  <h2>References</h2>
  <ol>
    <li>Project EPIC at University of Colorado Boulder</li>
    <li>Sandy-GIS Project from GIS 3 at University of Colorado Boulder (Spring 2014)</li>
  </ol>

</div>
