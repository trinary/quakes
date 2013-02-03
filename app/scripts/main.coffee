width = 960
height = 500

svg = d3.select(".main")
  .append("svg")
  .attr("width", width)
  .attr("height", height)

projection = d3.geo.robinson()

path = d3.geo.path()
  .projection(projection)

grat = d3.geo.graticule()

svg.append("path")
  .datum(grat)
  .attr("class","graticule")
  .attr("d",path)

svg.append("path")
  .datum(grat.outline)
  .attr("class","graticule outline")
  .attr("d",path)

tooltip = svg.append("g")
  .attr("class","tooltip")

colorscale = d3.scale.linear().domain([1,7]).range(["#ccc","#c33"])

clearTooltip = ->
  svg.select(".tooltip").remove()

drawTooltip = (d) ->
  ex = d3.event.pageX
  ey = d3.event.pageY

  svg.select(".tooltip")
    

queue()
  .defer(d3.json,"/scripts/vendor/world-110m.json")
  .defer(d3.csv, "/scripts/vendor/eqs7day-M1.txt")
  .await((err, world, quakes) -> 
    countries = topojson.object(world,world.objects.countries).geometries
    svg.selectAll(".country")
      .data(countries)
      .enter().insert("path",".graticule")
      .attr("class","country")
      .attr("d",path)

    coords = ( {date: d.Datetime, depth: d.Depth, region: d.Region, pos: projection([parseFloat(d.Lon), parseFloat(d.Lat)]), mag: parseFloat(d.Magnitude)} for d in quakes)
    svg.selectAll(".quake")
      .data(coords)
      .enter().insert("circle",".quake")
      .attr("cx",(d) -> d.pos[0])
      .attr("cy",(d) -> d.pos[1])
      .attr("r",0)
      .on("mouseover",drawTooltip)
      .on("mouseout",clearTooltip)
      .transition()
      .duration(1000)
      .delay((d,i) -> i* 20)
      .attr("r",(d) -> 0.5 + d.mag)
      .style("fill",(d) -> colorscale(d.mag))

  )
