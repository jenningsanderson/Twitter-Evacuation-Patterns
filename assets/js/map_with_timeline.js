$(document).ready(function(){

  var CODE_CATEGORIES = ["Sentiment", "Reporting", "Actions", "Preparation", "Information", "Movement", "Miscellaneous", "Other"]
  var BASE_COLORS = ["red","green","blue","yellow","orange","purple","pink","black"]

  var tweets = {}
  var chart_colors = {}

  //Populate these
  CODE_CATEGORIES.forEach(function(cat,i){
    chart_colors[cat] = BASE_COLORS[i]
    tweets[cat] = []
  })

  var group_ids = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

  function template(item){
    var html = '<div class="content">'
    html += '<p>'+item.content.replace(/_/g," ")+'</p>'
    html += '</div>'
    return html
  }

  // // add an OpenStreetMap tile layer
  // var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
  //   attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  // });
  //
  // //Call the map
  // var map = L.map("map").setView([51.505, -0.09], 13);;

  //Add baselayer
  // tiles.addTo(map);


  //Load the annotated tweets
  $.getJSON("/Twitter-Evacuation-Patterns/datasets/gold_anns_sample_2.json", function(data, err){
    Object.keys(data).forEach(function(key, idx) {
      //Tweets exist in a giant hash by tweet_id
      var tweet = data[key]

      // timeline_data[]
      // data_for_timeline.push({start: tweet.date, content: tweet.text, type: "point"})

      //Iterate over the annotations
      tweet.annotations.forEach(function(code){
        if (code != "None"){
          category = code.substring(0,code.indexOf('-'))
          value    = code.substring(code.indexOf('-')+1,code.length)

          tweets[category].push(
            {start: tweet.date,
             content: value,
             type: "point",
             style: "color: "+chart_colors[category],
             title: tweet.text,
             group: idx%21,
             id: idx+"_"+Math.random()+"_"+tweet.geo_coords
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
        }
      })
    })

    timeline_data = []

    Object.keys(tweets).forEach(function(key){
      tweets[key].forEach(function(tweet){
        timeline_data.push(tweet)
      })
    })

    //console.log(data_for_timeline)

    // Create a DataSet with data
    var timelineData = new vis.DataSet(timeline_data);

    var to_group = []
    group_ids.forEach(function(num){
      to_group.push( {id: num, content: 'User '+num } );
    })

    var groups = new vis.DataSet(to_group)

    // Set timeline options
    var timelineOptions = {
      "width":  "100%",
      "maxHeight":"600px",
      "minHeight":"300px",
      "autoResize": false,
      "style": "box",
      "axisOnTop": true,
      "showCustomTime":true,
      "max" : new Date(2012,10,10),
      "min" : new Date(2012,9,20),
      margin: { item: 1},
      clickToUse: true,
      template: template
    };

    function onSelect (properties) {
      console.log(properties);
    }

    // Setup timeline
    var timeline = new vis.Timeline(document.getElementById('timeline'), null, timelineOptions);

    timeline.setGroups(groups);
    timeline.setItems(timelineData);

    timeline.on('select', onSelect);

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
