"use strict";

const STEP5_BIOMES = [
  { name: "Water", color: "#1f5f9c", reason: "The height is below the shoreline.", priority: 100, h: [0, 0.31], t: [0, 1], m: [0, 1] },
  { name: "Beach", color: "#dccb91", reason: "The height is inside the narrow coast range.", priority: 90, h: [0.29, 0.39], t: [0, 1], m: [0, 1] },
  { name: "Snow", color: "#edf4f6", reason: "The terrain is high enough for the snow biome.", priority: 80, h: [0.82, 1], t: [0, 0.55], m: [0, 1] },
  { name: "Mountain", color: "#727b84", reason: "The height is above the mountain threshold.", priority: 70, h: [0.71, 1], t: [0, 1], m: [0, 1] },
  { name: "Desert", color: "#caa959", reason: "The terrain is warm and dry.", priority: 60, h: [0.38, 0.76], t: [0.58, 1], m: [0, 0.45] },
  { name: "Forest", color: "#2f7552", reason: "The terrain is temperate and moist.", priority: 55, h: [0.38, 0.76], t: [0.22, 0.75], m: [0.52, 1] },
  { name: "Plains", color: "#6eaa55", reason: "The terrain is mid-height without a stronger climate match.", priority: 10, h: [0.36, 0.76], t: [0, 1], m: [0, 1] }
];

function step5RangeDistance(value, range) {
  if (value < range[0]) return range[0] - value;
  if (value > range[1]) return value - range[1];
  return 0;
}

function selectStep5Biome(height, temperature, moisture) {
  const matches = STEP5_BIOMES
    .filter((biome) => height >= biome.h[0] && height <= biome.h[1]
      && temperature >= biome.t[0] && temperature <= biome.t[1]
      && moisture >= biome.m[0] && moisture <= biome.m[1])
    .sort((a, b) => b.priority - a.priority);

  if (matches.length > 0) {
    return matches[0];
  }

  return STEP5_BIOMES
    .map((biome) => ({
      biome,
      distance: step5RangeDistance(height, biome.h)
        + step5RangeDistance(temperature, biome.t)
        + step5RangeDistance(moisture, biome.m)
    }))
    .sort((a, b) => a.distance - b.distance)[0].biome;
}

function initializeStep5() {
  const inputIds = ["height5", "temperature5", "moisture5"];
  const swatch = document.getElementById("biomeSwatch5");
  const name = document.getElementById("biomeName5");
  const reason = document.getElementById("biomeReason5");

  if (!swatch || !name || !reason || inputIds.some((id) => !document.getElementById(id))) {
    return;
  }

  const render = () => {
    const height = TerrainDemo.readNumber("height5", 0.55);
    const temperature = TerrainDemo.readNumber("temperature5", 0.5);
    const moisture = TerrainDemo.readNumber("moisture5", 0.6);
    const biome = selectStep5Biome(height, temperature, moisture);

    TerrainDemo.setText("height5Value", height.toFixed(2));
    TerrainDemo.setText("temperature5Value", temperature.toFixed(2));
    TerrainDemo.setText("moisture5Value", moisture.toFixed(2));

    swatch.style.background = biome.color;
    name.textContent = biome.name;
    reason.textContent = biome.reason;
  };

  TerrainDemo.bindInputs(inputIds, render);
  render();
}

window.addEventListener("terrain:content-ready", initializeStep5);
