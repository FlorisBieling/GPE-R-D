"use strict";

function initializeStep4() {
  const heightCanvas = document.getElementById("heightCanvas4");
  const temperatureCanvas = document.getElementById("temperatureCanvas4");
  const moistureCanvas = document.getElementById("moistureCanvas4");
  const inputIds = ["climateSeed4", "temperatureScale4", "moistureScale4"];

  if (!heightCanvas || !temperatureCanvas || !moistureCanvas || inputIds.some((id) => !document.getElementById(id))) {
    return;
  }

  const render = () => {
    const seed = TerrainDemo.readNumber("climateSeed4", 24);
    const temperatureMultiplier = TerrainDemo.readNumber("temperatureScale4", 5);
    const moistureMultiplier = TerrainDemo.readNumber("moistureScale4", 6);
    const baseScale = 72;
    const settings = { octaves: 4, persistence: 0.5, lacunarity: 2 };

    TerrainDemo.setText("climateSeed4Value", String(Math.round(seed)));
    TerrainDemo.setText("temperatureScale4Value", temperatureMultiplier.toFixed(1));
    TerrainDemo.setText("moistureScale4Value", moistureMultiplier.toFixed(1));

    const height = TerrainDemo.generateNoiseMap(heightCanvas.width, heightCanvas.height, {
      ...settings,
      scale: baseScale,
      seed
    });

    const temperature = TerrainDemo.generateNoiseMap(temperatureCanvas.width, temperatureCanvas.height, {
      ...settings,
      scale: baseScale * temperatureMultiplier,
      seed: seed + 2,
      offsetX: 41,
      offsetY: -17
    });

    const moisture = TerrainDemo.generateNoiseMap(moistureCanvas.width, moistureCanvas.height, {
      ...settings,
      scale: baseScale * moistureMultiplier,
      seed: seed + 4,
      offsetX: -26,
      offsetY: 33
    });

    TerrainDemo.drawMap(heightCanvas, height, TerrainDemo.grayscale);
    TerrainDemo.drawMap(temperatureCanvas, temperature, (value) => [
      Math.round(TerrainDemo.lerp(42, 244, value)),
      Math.round(TerrainDemo.lerp(95, 149, value)),
      Math.round(TerrainDemo.lerp(184, 58, value)),
      255
    ]);
    TerrainDemo.drawMap(moistureCanvas, moisture, (value) => [
      Math.round(TerrainDemo.lerp(196, 40, value)),
      Math.round(TerrainDemo.lerp(157, 151, value)),
      Math.round(TerrainDemo.lerp(89, 214, value)),
      255
    ]);
  };

  TerrainDemo.bindInputs(inputIds, TerrainDemo.debounce(render, 45));
  render();
}

window.addEventListener("terrain:content-ready", initializeStep4);
