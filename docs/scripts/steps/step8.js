"use strict";

function initializeStep8() {
  const canvas = document.getElementById("snowCanvas8");
  const inputIds = ["snowStart8", "snowEnd8", "lineInfluence8", "holeStrength8"];

  if (!canvas || inputIds.some((id) => !document.getElementById(id)) || !window.noise) {
    return;
  }

  const render = () => {
    const startInput = TerrainDemo.readNumber("snowStart8", 0.75);
    const endInput = TerrainDemo.readNumber("snowEnd8", 0.85);
    const start = Math.min(startInput, endInput);
    const end = Math.max(startInput, endInput);
    const transition = Math.max(0.0001, end - start);
    const lineInfluence = TerrainDemo.readNumber("lineInfluence8", 0.08);
    const holeStrength = TerrainDemo.readNumber("holeStrength8", 0.25);

    TerrainDemo.setText("snowStart8Value", startInput.toFixed(2));
    TerrainDemo.setText("snowEnd8Value", endInput.toFixed(2));
    TerrainDemo.setText("lineInfluence8Value", lineInfluence.toFixed(2));
    TerrainDemo.setText("holeStrength8Value", holeStrength.toFixed(2));

    const width = canvas.width;
    const height = canvas.height;
    const values = new Float32Array(width * height);
    noise.seed(73);

    for (let y = 0; y < height; y += 1) {
      const terrainHeight = 1 - y / (height - 1);

      for (let x = 0; x < width; x += 1) {
        const lineNoise = (noise.perlin2(x / 88, 0.37) + 1) / 2;
        const localStart = start + (lineNoise - 0.5) * lineInfluence * 2;
        let amount = TerrainDemo.smoothstep(localStart, localStart + transition, terrainHeight);

        const holeNoise = (noise.perlin2(x / 35 + 9.132, y / 35 + 2.817) + 1) / 2;
        const holeAmount = TerrainDemo.smoothstep(0.45, 1, holeNoise) * holeStrength;
        amount = TerrainDemo.clamp(amount - holeAmount * (1 - TerrainDemo.smoothstep(end, 1, terrainHeight)));
        values[y * width + x] = amount;
      }
    }

    TerrainDemo.drawMap(canvas, values, (value, index) => {
      const y = Math.floor(index / width);
      const terrainHeight = 1 - y / (height - 1);
      const rock = Math.round(TerrainDemo.lerp(70, 135, terrainHeight));
      return [
        Math.round(TerrainDemo.lerp(rock, 242, value)),
        Math.round(TerrainDemo.lerp(rock + 4, 247, value)),
        Math.round(TerrainDemo.lerp(rock + 8, 250, value)),
        255
      ];
    });
  };

  TerrainDemo.bindInputs(inputIds, TerrainDemo.debounce(render, 35));
  render();
}

window.addEventListener("terrain:content-ready", initializeStep8);
