"use strict";

window.TerrainDemo = (() => {
  function clamp(value, min = 0, max = 1) {
    return Math.min(max, Math.max(min, value));
  }

  function lerp(a, b, t) {
    return a + (b - a) * t;
  }

  function smoothstep(edge0, edge1, value) {
    if (edge0 === edge1) {
      return value < edge0 ? 0 : 1;
    }

    const t = clamp((value - edge0) / (edge1 - edge0));
    return t * t * (3 - 2 * t);
  }

  function inverseLerp(a, b, value) {
    return a === b ? 0 : clamp((value - a) / (b - a));
  }

  function readNumber(id, fallback = 0) {
    const element = document.getElementById(id);
    if (!element) {
      return fallback;
    }

    const parsed = Number.parseFloat(element.value);
    return Number.isFinite(parsed) ? parsed : fallback;
  }

  function setText(id, value) {
    const element = document.getElementById(id);
    if (element) {
      element.textContent = value;
    }
  }

  function generateNoiseMap(width, height, options) {
    const values = new Float32Array(width * height);
    const octaves = Math.max(1, Math.floor(options.octaves ?? 1));
    const scale = Math.max(0.0001, options.scale ?? 40);
    const persistence = options.persistence ?? 0.5;
    const lacunarity = options.lacunarity ?? 2;
    const offsetX = options.offsetX ?? 0;
    const offsetY = options.offsetY ?? 0;
    const halfWidth = width / 2;
    const halfHeight = height / 2;

    noise.seed(options.seed ?? 0);

    let minimum = Number.POSITIVE_INFINITY;
    let maximum = Number.NEGATIVE_INFINITY;

    for (let y = 0; y < height; y += 1) {
      for (let x = 0; x < width; x += 1) {
        let amplitude = 1;
        let frequency = 1;
        let total = 0;

        for (let octave = 0; octave < octaves; octave += 1) {
          const sampleX = ((x - halfWidth + offsetX) / scale) * frequency;
          const sampleY = ((y - halfHeight + offsetY) / scale) * frequency;
          total += noise.perlin2(sampleX, sampleY) * amplitude;
          amplitude *= persistence;
          frequency *= lacunarity;
        }

        const index = y * width + x;
        values[index] = total;
        minimum = Math.min(minimum, total);
        maximum = Math.max(maximum, total);
      }
    }

    const range = maximum - minimum || 1;
    for (let index = 0; index < values.length; index += 1) {
      values[index] = (values[index] - minimum) / range;
    }

    return values;
  }

  function drawMap(canvas, values, colorFunction) {
    if (!canvas) {
      return;
    }

    const width = canvas.width;
    const height = canvas.height;
    const context = canvas.getContext("2d");
    const imageData = context.createImageData(width, height);

    for (let index = 0; index < values.length; index += 1) {
      const color = colorFunction(values[index], index) || [0, 0, 0];
      const pixelIndex = index * 4;
      imageData.data[pixelIndex] = color[0];
      imageData.data[pixelIndex + 1] = color[1];
      imageData.data[pixelIndex + 2] = color[2];
      imageData.data[pixelIndex + 3] = color[3] ?? 255;
    }

    context.putImageData(imageData, 0, 0);
  }

  function grayscale(value) {
    const channel = Math.round(clamp(value) * 255);
    return [channel, channel, channel, 255];
  }

  function debounce(callback, delay = 60) {
    let timeout;
    return (...args) => {
      window.clearTimeout(timeout);
      timeout = window.setTimeout(() => callback(...args), delay);
    };
  }

  function bindInputs(ids, callback) {
    ids.forEach((id) => {
      document.getElementById(id)?.addEventListener("input", callback);
    });
  }

  return {
    bindInputs,
    clamp,
    debounce,
    drawMap,
    generateNoiseMap,
    grayscale,
    inverseLerp,
    lerp,
    readNumber,
    setText,
    smoothstep
  };
})();
