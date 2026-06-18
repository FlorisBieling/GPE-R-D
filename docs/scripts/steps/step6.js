"use strict";

const STEP6_TEXTURES = [
  { name: "Water", h: [0, 0.31], t: [0, 1], m: [0, 1] },
  { name: "Beach", h: [0.29, 0.40], t: [0, 1], m: [0, 1] },
  { name: "Plains", h: [0.36, 0.76], t: [0, 1], m: [0.15, 0.78] },
  { name: "Forest", h: [0.38, 0.78], t: [0.18, 0.75], m: [0.48, 1] },
  { name: "Desert", h: [0.38, 0.75], t: [0.58, 1], m: [0, 0.45] },
  { name: "Mountain", h: [0.69, 0.93], t: [0, 1], m: [0, 1] },
  { name: "Snow", h: [0.80, 1], t: [0, 0.65], m: [0, 1] }
];

function step6RangeWeight(value, range, softness) {
  const fromMinimum = TerrainDemo.smoothstep(range[0] - softness, range[0] + softness, value);
  const fromMaximum = 1 - TerrainDemo.smoothstep(range[1] - softness, range[1] + softness, value);
  return TerrainDemo.clamp(fromMinimum * fromMaximum);
}

function calculateStep6Weights(height, temperature, moisture, softness) {
  if (height <= 0.3) {
    return STEP6_TEXTURES.map((texture) => texture.name === "Water" ? 1 : 0);
  }

  const weights = STEP6_TEXTURES.map((texture) => {
    if (texture.name === "Water") return 0;
    return step6RangeWeight(height, texture.h, softness)
      * step6RangeWeight(temperature, texture.t, softness)
      * step6RangeWeight(moisture, texture.m, softness);
  });

  const total = weights.reduce((sum, weight) => sum + weight, 0);
  if (total <= 0.00001) {
    const plainsIndex = STEP6_TEXTURES.findIndex((texture) => texture.name === "Plains");
    weights[plainsIndex] = 1;
    return weights;
  }

  return weights.map((weight) => weight / total);
}

function initializeStep6() {
  const inputIds = ["height6", "temperature6", "moisture6", "softness6"];
  const bars = document.getElementById("weightBars6");

  if (!bars || inputIds.some((id) => !document.getElementById(id))) {
    return;
  }

  STEP6_TEXTURES.forEach((texture, index) => {
    const row = document.createElement("div");
    row.className = "weight-row";
    row.innerHTML = `
      <span>${texture.name}</span>
      <div class="weight-track"><div class="weight-fill" data-weight-fill="${index}"></div></div>
      <span class="weight-value" data-weight-value="${index}">0%</span>
    `;
    bars.appendChild(row);
  });

  const render = () => {
    const height = TerrainDemo.readNumber("height6", 0.56);
    const temperature = TerrainDemo.readNumber("temperature6", 0.48);
    const moisture = TerrainDemo.readNumber("moisture6", 0.55);
    const softness = TerrainDemo.readNumber("softness6", 0.08);

    TerrainDemo.setText("height6Value", height.toFixed(2));
    TerrainDemo.setText("temperature6Value", temperature.toFixed(2));
    TerrainDemo.setText("moisture6Value", moisture.toFixed(2));
    TerrainDemo.setText("softness6Value", softness.toFixed(2));

    const weights = calculateStep6Weights(height, temperature, moisture, softness);
    weights.forEach((weight, index) => {
      const percentage = weight * 100;
      const fill = bars.querySelector(`[data-weight-fill="${index}"]`);
      const value = bars.querySelector(`[data-weight-value="${index}"]`);
      if (fill) fill.style.width = `${percentage.toFixed(2)}%`;
      if (value) value.textContent = `${Math.round(percentage)}%`;
    });
  };

  TerrainDemo.bindInputs(inputIds, render);
  render();
}

window.addEventListener("terrain:content-ready", initializeStep6);
