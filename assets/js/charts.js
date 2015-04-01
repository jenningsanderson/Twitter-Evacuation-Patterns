function makeBarChart(destination, data, title){
  var margin = {top: 80, right: 80, bottom: 100, left: 80},
    width  = 400 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

  var barWidth = 30;

  var chart = d3.select(destination)
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)

  var y = d3.scale.linear()
    .range([height, 0]);

  var yAxis = d3.svg.axis().scale(y).ticks(10).orient("left");

  y.domain([0, d3.max(data, function(d) { return d.value; })]);

  var bar = chart.selectAll("g")
    .data(data)
    .enter().append("g")
    .attr("transform", function(d, i) { return "translate(" + (margin.left + i * barWidth) + ","+margin.top+")"; });

  bar.append("rect")
    .attr("y", function(d) { return y(d.value); })
    .attr("height", function(d) { return height - y(d.value); })
    .attr("width", barWidth - 1);

  bar.append("text")
    .attr("y", height+10)
    .attr("x", barWidth/2 )
    .style("text-anchor", "end")
    .attr("dx", -height/2 - margin.top)
    .attr("dy", -margin.top)
    .attr("transform", function(d){return "rotate(-45)"})
    .text(function(d) { return d.label.replace(/_/g, " "); });

  chart.append("g")
    .attr("class", "y axis")
    .attr("transform", "translate(" + margin.left + ","+margin.top+")")
    .call(yAxis);

  chart.append("text")
      .attr("x", (margin.left + width / 2))
      .attr("y", (margin.top / 2))
      .attr("text-anchor", "middle")
      .style("font-size", "16px")
      .text(title);
 }













 function makeLineChart(destination, data, datatype){
   var margin = {top: 20, right: 20, bottom: 30, left: 50},
     width = 960 - margin.left - margin.right,
     height = 500 - margin.top - margin.bottom;

   var parseDate = d3.time.format("%a %b %d %Y %X GMT%Z (MDT)").parse;

   var x = d3.time.scale()
       .range([0, width]);

   var y = d3.scale.linear()
       .range([height, 0]);

   var xAxis = d3.svg.axis()
       .scale(x)
       .orient("bottom");

   var yAxis = d3.svg.axis()
       .scale(y)
       .orient("left");

   var line = d3.svg.line()
       .x(function(d) { return x(d.date); })
       .y(function(d) { console.log(d.count); return y(d.count); });

   var linechartgraphic = d3.select(destination)
       .attr("width", width + margin.left + margin.right)
       .attr("height", height + margin.top + margin.bottom)
       .append("g")
       .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

   for_graph = {}
   Object.keys(linechart[datatype]).forEach(function(sentiment_type){
     for_graph[sentiment_type] = []
     Object.keys(linechart.Sentiment[sentiment_type]).forEach(function(time){
       for_graph[sentiment_type].push( {
         date: parseDate(time),
         count: linechart.Sentiment[sentiment_type][time] })
     })
   })

   data = for_graph["Positive_Coping"]
     // d3.tsv("data.tsv", function(error, data) {
     //   data.forEach(function(d) {
     //     d.date = parseDate(d.date);
     //     d.close = +d.close;
     //   });
     //
   x.domain(d3.extent(data, function(d) { return d.date; }));
   y.domain(d3.extent(data, function(d) { return d.count; }));
     //
   linechartgraphic.append("g")
       .attr("class", "x axis")
       .attr("transform", "translate(0," + height + ")")
       .call(xAxis);

   linechartgraphic.append("g")
       .attr("class", "y axis")
       .call(yAxis)
       .append("text")
       .attr("transform", "rotate(-90)")
       .attr("y", 6)
       .attr("dy", ".71em")
       .style("text-anchor", "end")
       .text("Count");

   linechartgraphic.append("path")
       .datum(data)
       .attr("class", "line")
       .attr("d", line);
 }
