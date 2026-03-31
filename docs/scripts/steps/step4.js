let step4Cache = null;

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

function getHeightOnlyTerrainColor(heightValue) {
    if (heightValue < 0.28) {
        return [58, 119, 201];
    }

    if (heightValue < 0.36) {
        return [224, 211, 154];
    }

    if (heightValue < 0.68) {
        return [76, 166, 76];
    }

    return [130, 130, 130];
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

function drawSplitLine(ctx, splitX, height) {
    ctx.strokeStyle = "#ffffff";
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(splitX, 0);
    ctx.lineTo(splitX, height);
    ctx.stroke();
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
    drawSplitLine(ctx, splitX, height);
}

function drawStep4ResultMap(canvas, heightValues, temperatureValues, sliderPercent) {
    const width = canvas.width;
    const height = canvas.height;
    const ctx = canvas.getContext("2d");
    const imageData = ctx.createImageData(width, height);

    const splitX = Math.floor((sliderPercent / 100) * width);

    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            const index = y * width + x;
            const pixelIndex = index * 4;

            const color = x < splitX
                ? getHeightOnlyTerrainColor(heightValues[index])
                : getStep4BiomeColor(heightValues[index], temperatureValues[index]);

            imageData.data[pixelIndex] = color[0];
            imageData.data[pixelIndex + 1] = color[1];
            imageData.data[pixelIndex + 2] = color[2];
            imageData.data[pixelIndex + 3] = 255;
        }
    }

    ctx.putImageData(imageData, 0, 0);
    drawSplitLine(ctx, splitX, height);
}

function buildStep4Data() {
    const comparisonCanvas = document.getElementById("comparisonCanvas4");
    const biomeCanvas = document.getElementById("biomeCanvas4");

    if (!comparisonCanvas || !biomeCanvas || typeof noise === "undefined") {
        return null;
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

    return {
        heightValues,
        temperatureValues
    };
}

function renderStep4() {
    const comparisonCanvas = document.getElementById("comparisonCanvas4");
    const biomeCanvas = document.getElementById("biomeCanvas4");
    const slider = document.getElementById("comparisonSlider4");

    if (!comparisonCanvas || !biomeCanvas || !slider || !step4Cache) {
        return;
    }

    const sliderPercent = parseFloat(slider.value);

    drawStep4ComparisonMap(
        comparisonCanvas,
        step4Cache.heightValues,
        step4Cache.temperatureValues,
        sliderPercent
    );

    drawStep4ResultMap(
        biomeCanvas,
        step4Cache.heightValues,
        step4Cache.temperatureValues,
        sliderPercent
    );
}

function setupStep4() {
    const slider = document.getElementById("comparisonSlider4");
    const button = document.getElementById("generateStep4Button");

    if (!slider || !button || typeof noise === "undefined") {
        return;
    }

    step4Cache = buildStep4Data();

    if (!step4Cache) {
        return;
    }

    renderStep4();

    slider.addEventListener("input", renderStep4);
    button.addEventListener("click", generateNewStep4Map);
}

function generateNewStep4Map() {
    const comparisonCanvas = document.getElementById("comparisonCanvas4");

    if (!comparisonCanvas || typeof noise === "undefined") {
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

    const randomSeed1 = Math.floor(Math.random() * 10000);
    const randomSeed2 = Math.floor(Math.random() * 10000);

    const heightValues = generateStep4LayerMap(width, height, {
        ...baseSettings,
        seed: randomSeed1,
        scale: 80
    });

    const temperatureValues = generateStep4LayerMap(width, height, {
        ...baseSettings,
        seed: randomSeed2,
        scale: 400
    });

    step4Cache = {
        heightValues,
        temperatureValues
    };

    renderStep4();
}

window.addEventListener("stepsLoaded", setupStep4);