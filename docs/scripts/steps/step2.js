"use strict";

function initializeStep2() {
  const canvas = document.getElementById("noiseCanvas2");
  const required = ["noiseScale2", "octaves2", "persistence2", "lacunarity2", "noiseSeed2"];

  if (!canvas || required.some((id) => !document.getElementById(id)) || !window.TerrainDemo || !window.noise) {
    return;
  }

  const render = () => {
    const scale = TerrainDemo.readNumber("noiseScale2", 70);
    const octaves = TerrainDemo.readNumber("octaves2", 4);
    const persistence = TerrainDemo.readNumber("persistence2", 0.5);
    const lacunarity = TerrainDemo.readNumber("lacunarity2", 2);
    const seed = TerrainDemo.readNumber("noiseSeed2", 12);

    TerrainDemo.setText("scale2Value", String(Math.round(scale)));
    TerrainDemo.setText("octaves2Value", String(Math.round(octaves)));
    TerrainDemo.setText("persistence2Value", persistence.toFixed(2));
    TerrainDemo.setText("lacunarity2Value", lacunarity.toFixed(2));
    TerrainDemo.setText("seed2Value", String(Math.round(seed)));

    const values = TerrainDemo.generateNoiseMap(canvas.width, canvas.height, {
      scale,
      octaves,
      persistence,
      lacunarity,
      seed
    });

    TerrainDemo.drawMap(canvas, values, TerrainDemo.grayscale);
  };

  TerrainDemo.bindInputs(required, TerrainDemo.debounce(render, 40));
  render();
}

window.addEventListener("terrain:content-ready", initializeStep2);
