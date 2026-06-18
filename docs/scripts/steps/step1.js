"use strict";

function initializeStep1() {
  const canvas = document.getElementById("noiseCanvas");
  const scaleInput = document.getElementById("noiseScale");
  const seedInput = document.getElementById("noiseSeed");
  const button = document.getElementById("generateNoiseButton");

  if (!canvas || !scaleInput || !seedInput || !button || !window.TerrainDemo || !window.noise) {
    return;
  }

  const render = () => {
    const scale = TerrainDemo.readNumber("noiseScale", 40);
    const seed = TerrainDemo.readNumber("noiseSeed", 0);
    TerrainDemo.setText("scaleValue", String(Math.round(scale)));
    TerrainDemo.setText("seedValue", String(Math.round(seed)));

    const values = TerrainDemo.generateNoiseMap(canvas.width, canvas.height, {
      scale,
      seed,
      octaves: 1,
      persistence: 0.5,
      lacunarity: 2
    });

    TerrainDemo.drawMap(canvas, values, TerrainDemo.grayscale);
  };

  const scheduledRender = TerrainDemo.debounce(render, 35);
  TerrainDemo.bindInputs(["noiseScale", "noiseSeed"], scheduledRender);

  button.addEventListener("click", () => {
    seedInput.value = String(Math.floor(Math.random() * 101));
    render();
  });

  render();
}

window.addEventListener("terrain:content-ready", initializeStep1);
