Drawing with epicycles
======================

Video can be viewed [here](https://vimeo.com/347925024).

1. First create an SVG, eg, [hydra.svg](./hydra.svg).
2. Generate the HTML file used to extract the points from the SVG path:

   ```
   erb num_samples=1000 svg=hydra.svg points-from-svg.html.erb > points-from-svg.html
   ```
3. Open the generated HTML file in a browser and copy the points out of the DOM.
4. Save the points into "points.json"

   ```
   pbpaste > points.json # on OS X
   ```
5. Run the program

   ```
   ruby -s draw.rb
   ruby -s draw.rb -crosshairs
   ruby -s draw.rb -zoom=5 -centered
   ```
