"use strict";

function initializeStep3() {
  const canvas = document.getElementById("noiseCanvas3");
  const seedButton = document.getElementById("generateStep3Button");
  const inputIds = ["noiseScale3", "waterThreshold3", "beachThreshold3", "mountainThreshold3"];

  if (!canvas || !seedButton || inputIds.some((id) => !document.getElementById(id)) || !window.TerrainDemo) {
    return;
  }

  let seed = 31;

  const render = () => {
    const scale = TerrainDemo.readNumber("noiseScale3", 85);
    const water = TerrainDemo.readNumber("waterThreshold3", 0.32);
    const beach = Math.max(water, TerrainDemo.readNumber("beachThreshold3", 0.39));
    const mountain = Math.max(beach, TerrainDemo.readNumber("mountainThreshold3", 0.72));

    TerrainDemo.setText("scale3Value", String(Math.round(scale)));
    TerrainDemo.setText("water3Value", water.toFixed(2));
    TerrainDemo.setText("beach3Value", beach.toFixed(2));
    TerrainDemo.setText("mountain3Value", mountain.toFixed(2));

    const values = TerrainDemo.generateNoiseMap(canvas.width, canvas.height, {
      scale,
      octaves: 5,
      persistence: 0.5,
      lacunarity: 2,
      seed
    });

    TerrainDemo.drawMap(canvas, values, (value) => {
      if (value < water) return [31, 83, 145, 255];
      if (value < beach) return [220, 202, 145, 255];
      if (value < mountain) return [62, 139, 80, 255];
      return [116, 123, 132, 255];
    });
  };

  TerrainDemo.bindInputs(inputIds, TerrainDemo.debounce(render, 45));
  seedButton.addEventListener("click", () => {
    seed = Math.floor(Math.random() * 10000);
    render();
  });

  render();
}

window.addEventListener("terrain:content-ready", initializeStep3);
