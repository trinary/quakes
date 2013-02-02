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

colorscale = d3.scale.linear().domain([1,7]).range(["#ccc","#c33"])

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

    coords = ( {pos: projection([parseFloat(d.Lon), parseFloat(d.Lat)]), mag: parseFloat(d.Magnitude)} for d in quakes)
    console.log coords
    svg.selectAll(".quake")
      .data(coords)
      .enter().insert("circle",".quake")
      .attr("cx",(d) -> d.pos[0])
      .attr("cy",(d) -> d.pos[1])
      .attr("r",(d) -> 0.5 + d.mag)
      .style("fill",(d) -> colorscale(d.mag))
  )
