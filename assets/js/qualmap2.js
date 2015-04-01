// Leaflet & JQuery have already been loaded
//
//
//
//

$(document).ready(function(){

  var codes = {
    Sentiment: {},
    Movement:  {},
    Miscellaneous: {},
    Reporting: {},
    Actions: {},
    Information: {},
    Preparation: {},
    Other: {}
  }

  var map_annotate_layers = {
    Sentiment: [],
    Movement:  [],
    Miscellaneous: [],
    Reporting: [],
    Actions: [],
    Information: [],
    Preparation: [],
    Other: []
  }

  var data_for_timeline = []

  // add an OpenStreetMap tile layer
  var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  });

  //Call the map
  var map = L.map("map").setView([51.505, -0.09], 13);;

  //Add baselayer
  tiles.addTo(map);

  linechart = {
    Sentiment: {},
    Movement:  {},
    Miscellaneous: {},
    Reporting: {},
    Actions: {},
    Information: {},
    Preparation: {},
    Other: {}
  }

  //Load the annotated tweets
  $.getJSON("/Twitter-Evacuation-Patterns/datasets/gold_sample.json", function(data, err){
    Object.keys(data).forEach(function (key) {
      var tweet = data[key]

      // data_for_timeline.push({start: tweet.date, content: tweet.text, type: "point"})

      tweet.annotations.forEach(function(code){
        if (code != "None"){
          category = code.substring(0,code.indexOf('-'))
          value    = code.substring(code.indexOf('-')+1,code.length)

          data_for_timeline.push({start: tweet.date, content: value, type: "point"})

          var coeff = 1000 * 60 * 24;
          var trunk_time = new Date(Math.round(Date.parse(tweet.date) / coeff) * coeff)

          if (codes[category][value] == undefined){
            codes[category][value] =  1
            linechart[category][value] = {}
            linechart[category][value][trunk_time] = 1
          }else{
            codes[category][value] += 1
            if (linechart[category][value][trunk_time] == undefined){
              linechart[category][value][trunk_time] =  1
            }else{
              linechart[category][value][trunk_time] += 1
            }
          }
        }
      })
    })

    console.log(linechart)

    //console.log(data_for_timeline)

    // Create a DataSet with data
    var timelineData = new vis.DataSet(data_for_timeline);

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
      "min" : new Date(2012,9,20)
    };

    // Setup timeline
    var timeline = new vis.Timeline(document.getElementById('timeline'), timelineData, timelineOptions);

    // Set custom time marker (blue)
    timeline.setCustomTime(new Date(2012,9,29));

     var sentiments = []
     //Now put it into a chart!
     Object.keys(codes.Sentiment).forEach(function (key) {
       sentiments.push( {label: key, value: parseInt(codes.Sentiment[key])} )
     })
     makeBarChart("#sentiment_chart",sentiments,"Sentiment")

     var actions = []
     //Now put it into a chart!
     Object.keys(codes.Actions).forEach(function (key) {
       actions.push( {label: key, value: parseInt(codes.Actions[key])} )
     })
     makeBarChart("#action_chart",actions,"Actions")

     var reporting = []
     //Now put it into a chart!
     Object.keys(codes.Reporting).forEach(function (key) {
       reporting.push( {label: key, value: parseInt(codes.Reporting[key])} )
     })
     makeBarChart("#reporting_chart",reporting,"Reporting")

     var Movement = []
     //Now put it into a chart!
     Object.keys(codes.Movement).forEach(function (key) {
       Movement.push( {label: key, value: parseInt(codes.Movement[key])} )
     })
     makeBarChart("#movement_chart",Movement,"Movement")

     var Miscellaneous = []
     //Now put it into a chart!
     Object.keys(codes.Miscellaneous).forEach(function (key) {
       Miscellaneous.push( {label: key, value: parseInt(codes.Miscellaneous[key])} )
     })
     makeBarChart("#miscellaneous_chart",Miscellaneous,"Miscellaneous")



     /*
        Working on Relative Frequency Now
     */


    makeLineChart("#sentiment_linechart", linechart, "Sentiment")
  })
})
