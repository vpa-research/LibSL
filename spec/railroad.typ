#import "@preview/fervojo:0.1.1"

#let railroad = fervojo.render.with(css:
  ```css
  svg.railroad rect.railroad_canvas {
    stroke-width: 0pt;
    fill: none;
  }

  svg.railroad path {
    stroke-width: 1pt;
    stroke: black;
    fill: none;
  }

  svg.railroad .debug {
    stroke-width: 1pt;
    stroke: red;
  }

  svg.railroad text {
    font: 10pt "Ubuntu Mono";
    text-anchor: middle;
  }

  svg.railroad .nonterminal text {
    font-family: "Libertinus Serif";
    font-weight: bold;
  }

  svg.railroad text.comment {
    font-family: "Libertinus Serif";
    font-style: italic;
  }

  svg.railroad rect {
    stroke-width: 1pt;
    stroke: black;
    fill: #eee;
  }

  svg.railroad g.labeledbox > rect {
    stroke-width: 0.75pt;
    stroke: grey;
    stroke-dasharray: 2.5pt;
    fill: #eee;
  }
  ```,
)