function generateStep4LayerMap(width, height, config) {
    const values = new Array(width * height);
    let minNoiseHeight = Infinity;
    let maxNoiseHeight = -Infinity;

    noise.seed(config.seed);

    const halfWidth = width / 2;
    const halfHeight = height / 2;

    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            let amplitude = 1;
            let frequency = 1;
            let noiseHeight = 0;

            for (let i = 0; i < config.octaves; i++) {
                const sampleX = (x - halfWidth + config.offsetX) / config.scale * frequency;
                const sampleY = (y - halfHeight + config.offsetY) / config.scale * frequency;

                const perlinValue = noise.perlin2(sampleX, sampleY);
                noiseHeight += perlinValue * amplitude;

                amplitude *= config.persistence;
                frequency *= config.lacunarity;
            }

            const index = y * width + x;
            values[index] = noiseHeight;

            if (noiseHeight < minNoiseHeight) {
                minNoiseHeight = noiseHeight;
            }

            if (noiseHeight > maxNoiseHeight) {
                maxNoiseHeight = noiseHeight;
            }
        }
    }

    const range = maxNoiseHeight - minNoiseHeight || 1;

    for (let i = 0; i < values.length; i++) {
        values[i] = (values[i] - minNoiseHeight) / range;
    }

    return values;
}

function drawStep4ComparisonMap(canvas, heightValues, temperatureValues, sliderPercent) {
    const width = canvas.width;
    const height = canvas.height;
    const ctx = canvas.getContext("2d");
    const imageData = ctx.createImageData(width, height);

    const splitX = Math.floor((sliderPercent / 100) * width);

    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            const index = y * width + x;
            const pixelIndex = index * 4;

            const value = x < splitX ? heightValues[index] : temperatureValues[index];
            const color = Math.floor(value * 255);

            imageData.data[pixelIndex] = color;
            imageData.data[pixelIndex + 1] = color;
            imageData.data[pixelIndex + 2] = color;
            imageData.data[pixelIndex + 3] = 255;
        }
    }

    ctx.putImageData(imageData, 0, 0);

    ctx.strokeStyle = "#ffffff";
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(splitX, 0);
    ctx.lineTo(splitX, height);
    ctx.stroke();
}

function getStep4BiomeColor(heightValue, temperatureValue) {
    if (heightValue < 0.28) {
        if (temperatureValue < 0.45) {
            return [45, 82, 145];
        }
        return [58, 119, 201];
    }

    if (heightValue < 0.36) {
        if (temperatureValue < 0.45) {
            return [192, 198, 168];
        }
        return [224, 211, 154];
    }

    if (heightValue < 0.68) {
        if (temperatureValue < 0.30) {
            return [168, 196, 211];
        }

        if (temperatureValue < 0.65) {
            return [76, 166, 76];
        }

        return [201, 179, 94];
    }

    if (temperatureValue < 0.45) {
        return [240, 240, 240];
    }

    return [130, 130, 130];
}

function drawStep4BiomeMap(canvas, heightValues, temperatureValues) {
    const width = canvas.width;
    const height = canvas.height;
    const ctx = canvas.getContext("2d");
    const imageData = ctx.createImageData(width, height);

    for (let i = 0; i < heightValues.length; i++) {
        const color = getStep4BiomeColor(heightValues[i], temperatureValues[i]);
        const pixelIndex = i * 4;

        imageData.data[pixelIndex] = color[0];
        imageData.data[pixelIndex + 1] = color[1];
        imageData.data[pixelIndex + 2] = color[2];
        imageData.data[pixelIndex + 3] = 255;
    }

    ctx.putImageData(imageData, 0, 0);
}

function buildStep4Maps() {
    const comparisonCanvas = document.getElementById("comparisonCanvas4");
    const biomeCanvas = document.getElementById("biomeCanvas4");
    const slider = document.getElementById("comparisonSlider4");

    if (!comparisonCanvas || !biomeCanvas || !slider || typeof noise === "undefined") {
        return;
    }

    const width = comparisonCanvas.width;
    const height = comparisonCanvas.height;

    const baseSettings = {
        octaves: 4,
        persistence: 0.5,
        lacunarity: 2,
        offsetX: 0,
        offsetY: 0
    };

    const heightValues = generateStep4LayerMap(width, height, {
        ...baseSettings,
        seed: 42,
        scale: 80
    });

    const temperatureValues = generateStep4LayerMap(width, height, {
        ...baseSettings,
        seed: 44,
        scale: 400
    });

    drawStep4ComparisonMap(
        comparisonCanvas,
        heightValues,
        temperatureValues,
        parseFloat(slider.value)
    );

    drawStep4BiomeMap(biomeCanvas, heightValues, temperatureValues);
}

function setupStep4() {
    const slider = document.getElementById("comparisonSlider4");

    if (!slider) {
        return;
    }

    buildStep4Maps();
    slider.addEventListener("input", buildStep4Maps);
}

window.addEventListener("stepsLoaded", setupStep4);