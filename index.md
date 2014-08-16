---
layout: default
---


![Header Imge]({{site.baseurl}}/img_exports/header_img.png "Google Earth Example")

<div class="home">

  <h1>The Spacetime of Twitter</h1>

  <p>The goal of this project is to identify potential evacuation behavior based on geotags and timestamps within a Twitterer's contextual stream (EPIC).

  </p>
  <br />

  <p>This project is a continuation of work previously done with Andrew Hardin and Ellie Falletta in CU Geography 5303 (Spring 2014)</p>

  <br>
  <hr>
  <h2>Contents</h2>

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