$(document).ready(function(){

  var CODE_CATEGORIES = ["Sentiment", "Reporting", "Actions", "Preparation", "Information", "Movement", "Miscellaneous", "Other"]
  var BASE_COLORS = ["red","green","blue","purple","orange","olive","pink","black"]

  var tweets = {noCode:[]}
  var chart_colors = {}
  var users = {}
  var thisUserForMap = undefined
  var tweetIds = {}

  //Populate these
  CODE_CATEGORIES.forEach(function(cat,i){
    chart_colors[cat] = BASE_COLORS[i]
    tweets[cat] = []
  })

  function template(item){
    var html = '<div class="content">'
    html += '<p>'+item.content.replace(/_/g," ")+'</p>'
    html += '</div>'
    return html
  }

  //Call the map
  var map = L.map('map', {scrollWheelZoom: false}).setView([51.505, -0.09], 13);
  // map.on('focus', function() { map.scrollWheelZoom.enable(); });

  // add an OpenStreetMap tile layer
  var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);
  //

  function updateMap(tweets, start_date, end_date){
    if (thisUserForMap != undefined){ map.removeLayer(thisUserForMap) }
    thisUser = {type: "FeatureCollection", features:[]}
    tweets.forEach(function(tweet){
      if ( (Date.parse(tweet.date) < end_date) & (Date.parse(tweet.date) > start_date) ){
        if (tweet.geo_coords.length>2){
          var coordsString = tweet.geo_coords.substring(1,tweet.geo_coords.length-1).split(' ')
          var coords = [ parseFloat(coordsString[0]), parseFloat(coordsString[1]) ]
          thisUser.features.push( {properties: {annotations: tweet.annotations, name: tweet.user, text: tweet.text, time: tweet.date}, type: "Feature", geometry: {type: "Point", coordinates: coords}} )
        }
      }
    });

    thisUserForMap = L.geoJson(thisUser, {
      onEachFeature: function (feature, layer) {
        layer.bindPopup("<strong>Handle:</strong> "+feature.properties.name+
          "<br>"+"<strong>Date:</strong> "+feature.properties.time+
          "<br>"+"<strong>Text:</strong> "+feature.properties.text+
          "<br>"+"<strong>Code:</strong> "+feature.properties.annotations.toString());
      }
    });

    thisUserForMap.addTo(map)
    if (thisUserForMap != undefined){ map.fitBounds(thisUserForMap.getBounds());}
  }

  // Add baselayer
  tiles.addTo(map);


  //Load the annotated tweets
  $.getJSON("/Twitter-Evacuation-Patterns/datasets/dataset1.json", function(data, err){
    Object.keys(data).forEach(function(key, idx) {
      //Tweets exist in a giant hash by tweet_id
      var tweet = data[key]

      if (tweetIds[tweet.id]==undefined){tweetIds[tweet.id]=tweet}

      if (users[tweet.user] == undefined){users[tweet.user] = []}
      else{ users[tweet.user].push(tweet)}

      // timeline_data[]
      // data_for_timeline.push({start: tweet.date, content: tweet.text, type: "point"})

      //Iterate over the annotations
      tweet.annotations.forEach(function(code){
        if (code != "None"){
          category = code.substring(0,code.indexOf('-'))
          value    = code.substring(code.indexOf('-')+1,code.length)

          tweets[category].push(
            {start: tweet.date,
             content: '<p class="rotate">'+value+'</p>',
             type: "point",
             style: "color: "+chart_colors[category],
             title: tweet.text,
             group: tweet.user,
             id: tweet.id+"_"+Math.random().toString()
             }
          )

          // var coeff = 1000 * 60 * 24;
          // var trunk_time = new Date(Math.round(Date.parse(tweet.date) / coeff) * coeff)

          // if (codes[category][value] == undefined){
          //   codes[category][value] =  1
          //   linechart[category][value] = {}
          //   linechart[category][value][trunk_time] = 1
          // }else{
          //   codes[category][value] += 1
          //   if (linechart[category][value][trunk_time] == undefined){
          //     linechart[category][value][trunk_time] =  1
          //   }else{
          //     linechart[category][value][trunk_time] += 1
          //   }
          // }
        }else if(tweet.geo_coords.length > 2){
          tweets.noCode.push({
            start: tweet.date,
            content: '',
            type: "point",
            title: tweet.text,
            group: tweet.user,
            id: tweet.id+"_"+Math.random().toString()
          })
        }
      })
    })

    var timeline_data = []

    Object.keys(tweets).forEach(function(key){
      tweets[key].forEach(function(tweet){
        timeline_data.push(tweet)
      })
    })

    //console.log(data_for_timeline)

    // Create a DataSet with data
    var timelineData = new vis.DataSet(timeline_data);

    var to_group = []
    Object.keys(users).forEach(function(user){
      to_group.push( {id: user, content: user } );
    })

    var groups = new vis.DataSet(to_group)

    // Set timeline options
    var timelineOptions = {
      "width":  "100%",
      "maxHeight":"600px",
      "minHeight":"300px",
      "autoResize": false,
      "style": "box",
      "stack": false,
      "axisOnTop": true,
      "showCustomTime":true,
      "max" : new Date(2012,10,10),
      "min" : new Date(2012,9,20),
      margin: { item: '8px'},
      clickToUse: true,
      template: template
    };


    // Setup timeline
    var timeline = new vis.Timeline(document.getElementById('timeline'), null, timelineOptions);
    var activeUser = Object.keys(users)[0]
    timeline.setGroups(groups);
    timeline.setItems(timelineData);

    timeline.on('doubleClick', function(properties){
      activeUser = properties.group
      tweets = users[activeUser]
      var bounds = timeline.getWindow()
      updateMap(tweets, bounds.start, bounds.end)
    });

    timeline.on('rangechanged', function(properties){
      updateMap(users[activeUser], properties.start, properties.end)
    });

    var RedIcon = L.Icon.Default.extend({
            options: {
            	    iconUrl: '../assets/icons/marker-icon-red.png'
            }
         });
    var m = null

    timeline.on('select', function(properties){
      if (m!= null){map.removeLayer(m), m=null}
      properties.items.forEach(function(item){
        var tweet = tweetIds[item.split("_")[0]]
        if (activeUser != tweet.user){
          activeUser = tweet.user
          bounds = timeline.getWindow();
          updateMap(users[activeUser], bounds.start, bounds.end)
        }
        if (tweet.geo_coords.length>2){
          var coordsString = tweet.geo_coords.substring(1,tweet.geo_coords.length-1).split(' ')
          var coords = [ parseFloat(coordsString[0]), parseFloat(coordsString[1]) ]
          m = L.marker([coords[1], coords[0]],{
            icon: new RedIcon(),
            zIndexOffset: 1000
          }).addTo(map);
          m.bindPopup("<strong>Handle:</strong> "+tweet.user+
            "<br>"+"<strong>Date:</strong> "+tweet.date+
            "<br>"+"<strong>Text:</strong> "+tweet.text+
            "<br>"+"<strong>Code:</strong> "+tweet.annotations.toString()).openPopup();
        }
      })
      if ( (m!=undefined) & (m!=null) ){ map.panTo(m.getLatLng()); }
    });

    // timeline.on('select', function(properties){
    //   console.log(properties)
    // });

    // Set custom time marker (blue)
    timeline.setCustomTime(new Date(2012,9,29));

    //  var sentiments = []
    //  //Now put it into a chart!
    //  Object.keys(codes.Sentiment).forEach(function (key) {
    //    sentiments.push( {label: key, value: parseInt(codes.Sentiment[key])} )
    //  })
    //  makeBarChart("#sentiment_chart",sentiments,"Sentiment")
     //
    //  var actions = []
    //  //Now put it into a chart!
    //  Object.keys(codes.Actions).forEach(function (key) {
    //    actions.push( {label: key, value: parseInt(codes.Actions[key])} )
    //  })
    //  makeBarChart("#action_chart",actions,"Actions")
     //
    //  var reporting = []
    //  //Now put it into a chart!
    //  Object.keys(codes.Reporting).forEach(function (key) {
    //    reporting.push( {label: key, value: parseInt(codes.Reporting[key])} )
    //  })
    //  makeBarChart("#reporting_chart",reporting,"Reporting")
     //
    //  var Movement = []
    //  //Now put it into a chart!
    //  Object.keys(codes.Movement).forEach(function (key) {
    //    Movement.push( {label: key, value: parseInt(codes.Movement[key])} )
    //  })
    //  makeBarChart("#movement_chart",Movement,"Movement")
     //
    //  var Miscellaneous = []
    //  //Now put it into a chart!
    //  Object.keys(codes.Miscellaneous).forEach(function (key) {
    //    Miscellaneous.push( {label: key, value: parseInt(codes.Miscellaneous[key])} )
    //  })
    //  makeBarChart("#miscellaneous_chart",Miscellaneous,"Miscellaneous")

     /*
        Working on Relative Frequency Now
     */

    // makeLineChart("#sentiment_linechart", linechart, "Sentiment")
  })
})
