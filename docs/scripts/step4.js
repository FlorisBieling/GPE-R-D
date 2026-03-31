function generateStep4Noise(x, y, settings) {
    let amplitude = 1;
    let frequency = 1;
    let noiseHeight = 0;

    for (let i = 0; i < settings.octaves; i++) {
        const sampleX = (x - settings.halfWidth) / settings.scale * frequency;
        const sampleY = (y - settings.halfHeight) / settings.scale * frequency;

        let perlinValue = noise.perlin2(sampleX, sampleY);
        perlinValue = perlinValue * 2 - 1;

        noiseHeight += perlinValue * amplitude;

        amplitude *= settings.persistence;
        frequency *= settings.lacunarity;
    }

    return noiseHeight;
}

function normalizeNoiseValues(values) {
    let min = Infinity;
    let max = -Infinity;

    for (let i = 0; i < values.length; i++) {
        if (values[i] < min) {
            min = values[i];
        }

        if (values[i] > max) {
            max = values[i];
        }
    }

    const range = max - min || 1;
    const normalized = new Array(values.length);

    for (let i = 0; i < values.length; i++) {
        normalized[i] = (values[i] - min) / range;
    }

    return normalized;
}

function getBiomeColor(heightValue, temperatureValue) {
    if (heightValue < 0.35) {
        if (temperatureValue < 0.4) {
            return [52, 95, 181];
        }

        return [70, 140, 220];
    }

    if (heightValue < 0.42) {
        if (temperatureValue < 0.4) {
            return [201, 207, 170];
        }

        return [224, 211, 154];
    }

    if (heightValue < 0.7) {
        if (temperatureValue < 0.3) {
            return [167, 198, 214];
        }

        if (temperatureValue < 0.65) {
            return [76, 166, 76];
        }

        return [210, 186, 92];
    }

    if (temperatureValue < 0.45) {
        return [240, 240, 240];
    }

    return [130, 130, 130];
}

function drawGrayscaleMap(canvas, values) {
    const width = canvas.width;
    const height = canvas.height;
    const ctx = canvas.getContext("2d");
    const imageData = ctx.createImageData(width, height);

    for (let i = 0; i < values.length; i++) {
        const color = Math.floor(values[i] * 255);
        const pixelIndex = i * 4;

        imageData.data[pixelIndex] = color;
        imageData.data[pixelIndex + 1] = color;
        imageData.data[pixelIndex + 2] = color;
        imageData.data[pixelIndex + 3] = 255;
    }

    const tempCanvas = document.createElement("canvas");
    tempCanvas.width = width;
    tempCanvas.height = height;

    const tempCtx = tempCanvas.getContext("2d");
    tempCtx.putImageData(imageData, 0, 0);

    ctx.clearRect(0, 0, width, height);
    ctx.imageSmoothingEnabled = false;
    ctx.drawImage(tempCanvas, 0, 0, width, height);
}

function drawBiomeMap(canvas, heightValues, temperatureValues) {
    const width = canvas.width;
    const height = canvas.height;
    const ctx = canvas.getContext("2d");
    const imageData = ctx.createImageData(width, height);

    for (let i = 0; i < heightValues.length; i++) {
        const color = getBiomeColor(heightValues[i], temperatureValues[i]);
        const pixelIndex = i * 4;

        imageData.data[pixelIndex] = color[0];
        imageData.data[pixelIndex + 1] = color[1];
        imageData.data[pixelIndex + 2] = color[2];
        imageData.data[pixelIndex + 3] = 255;
    }

    const tempCanvas = document.createElement("canvas");
    tempCanvas.width = width;
    tempCanvas.height = height;

    const tempCtx = tempCanvas.getContext("2d");
    tempCtx.putImageData(imageData, 0, 0);

    ctx.clearRect(0, 0, width, height);
    ctx.imageSmoothingEnabled = false;
    ctx.drawImage(tempCanvas, 0, 0, width, height);
}

function drawStep4Maps() {
    const heightCanvas = document.getElementById("heightCanvas4");
    const temperatureCanvas = document.getElementById("temperatureCanvas4");
    const biomeCanvas = document.getElementById("biomeCanvas4");

    if (!heightCanvas || !temperatureCanvas || !biomeCanvas || typeof noise === "undefined") {
        return;
    }

    const width = 300;
    const height = 300;

    const heightSettings = {
        scale: Math.max(0.0001, parseFloat(document.getElementById("heightScale4").value) || 1),
        octaves: parseInt(document.getElementById("heightOctaves4").value, 10) || 1,
        persistence: parseFloat(document.getElementById("heightPersistence4").value) || 0.5,
        lacunarity: parseFloat(document.getElementById("heightLacunarity4").value) || 2,
        halfWidth: width / 2,
        halfHeight: height / 2
    };

    const temperatureSettings = {
        scale: Math.max(0.0001, parseFloat(document.getElementById("temperatureScale4").value) || 1),
        octaves: parseInt(document.getElementById("temperatureOctaves4").value, 10) || 1,
        persistence: parseFloat(document.getElementById("temperaturePersistence4").value) || 0.5,
        lacunarity: parseFloat(document.getElementById("temperatureLacunarity4").value) || 2,
        halfWidth: width / 2,
        halfHeight: height / 2
    };

    const rawHeightValues = new Array(width * height);
    const rawTemperatureValues = new Array(width * height);

    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            const index = y * width + x;
            rawHeightValues[index] = generateStep4Noise(x, y, heightSettings);
            rawTemperatureValues[index] = generateStep4Noise(x, y, temperatureSettings);
        }
    }

    const normalizedHeightValues = normalizeNoiseValues(rawHeightValues);
    const normalizedTemperatureValues = normalizeNoiseValues(rawTemperatureValues);

    drawGrayscaleMap(heightCanvas, normalizedHeightValues);
    drawGrayscaleMap(temperatureCanvas, normalizedTemperatureValues);
    drawBiomeMap(biomeCanvas, normalizedHeightValues, normalizedTemperatureValues);
}

function updateStep4SliderValues() {
    document.getElementById("heightScale4Value").textContent = document.getElementById("heightScale4").value;
    document.getElementById("heightOctaves4Value").textContent = document.getElementById("heightOctaves4").value;
    document.getElementById("heightPersistence4Value").textContent = parseFloat(document.getElementById("heightPersistence4").value).toFixed(2);
    document.getElementById("heightLacunarity4Value").textContent = parseFloat(document.getElementById("heightLacunarity4").value).toFixed(2);

    document.getElementById("temperatureScale4Value").textContent = document.getElementById("temperatureScale4").value;
    document.getElementById("temperatureOctaves4Value").textContent = document.getElementById("temperatureOctaves4").value;
    document.getElementById("temperaturePersistence4Value").textContent = parseFloat(document.getElementById("temperaturePersistence4").value).toFixed(2);
    document.getElementById("temperatureLacunarity4Value").textContent = parseFloat(document.getElementById("temperatureLacunarity4").value).toFixed(2);
}

function setupStep4() {
    const inputs = [
        "heightScale4",
        "heightOctaves4",
        "heightPersistence4",
        "heightLacunarity4",
        "temperatureScale4",
        "temperatureOctaves4",
        "temperaturePersistence4",
        "temperatureLacunarity4"
    ].map(id => document.getElementById(id));

    const button = document.getElementById("generateNoiseButton4");

    if (inputs.some(input => !input) || !button) {
        return;
    }

    inputs.forEach(input => {
        input.addEventListener("input", () => {
            updateStep4SliderValues();
            drawStep4Maps();
        });
    });

    button.addEventListener("click", drawStep4Maps);

    updateStep4SliderValues();
    drawStep4Maps();
}

window.addEventListener("stepsLoaded", setupStep4);