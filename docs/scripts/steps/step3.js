function generateStep3Noise(x, y, settings) {
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

function getTerrainColor(value, thresholds) {
    if (value < thresholds.water) {
        return [54, 116, 217];
    }

    if (value < thresholds.beach) {
        return [224, 211, 154];
    }

    if (value < thresholds.mountain) {
        return [76, 166, 76];
    }

    return [130, 130, 130];
}

function drawTerrainMap() {
    const scaleInput = document.getElementById("noiseScale3");
    const octavesInput = document.getElementById("octaves3");
    const persistenceInput = document.getElementById("persistence3");
    const lacunarityInput = document.getElementById("lacunarity3");
    const waterInput = document.getElementById("waterThreshold");
    const beachInput = document.getElementById("beachThreshold");
    const mountainInput = document.getElementById("mountainThreshold");
    const canvas = document.getElementById("noiseCanvas3");

    if (
        !scaleInput ||
        !octavesInput ||
        !persistenceInput ||
        !lacunarityInput ||
        !waterInput ||
        !beachInput ||
        !mountainInput ||
        !canvas ||
        typeof noise === "undefined"
    ) {
        return;
    }

    const mapWidth = 400;
    const mapHeight = 400;

    const settings = {
        scale: Math.max(0.0001, parseFloat(scaleInput.value) || 1),
        octaves: parseInt(octavesInput.value, 10) || 1,
        persistence: parseFloat(persistenceInput.value) || 0.5,
        lacunarity: parseFloat(lacunarityInput.value) || 2,
        halfWidth: mapWidth / 2,
        halfHeight: mapHeight / 2
    };

    const thresholds = {
        water: parseFloat(waterInput.value) || 0.35,
        beach: parseFloat(beachInput.value) || 0.42,
        mountain: parseFloat(mountainInput.value) || 0.7
    };

    if (thresholds.beach < thresholds.water) {
        thresholds.beach = thresholds.water;
    }

    if (thresholds.mountain < thresholds.beach) {
        thresholds.mountain = thresholds.beach;
    }

    const ctx = canvas.getContext("2d");
    const imageData = ctx.createImageData(mapWidth, mapHeight);

    const values = new Array(mapWidth * mapHeight);
    let minNoiseHeight = Infinity;
    let maxNoiseHeight = -Infinity;

    for (let y = 0; y < mapHeight; y++) {
        for (let x = 0; x < mapWidth; x++) {
            const noiseHeight = generateStep3Noise(x, y, settings);
            const index = y * mapWidth + x;

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

    for (let y = 0; y < mapHeight; y++) {
        for (let x = 0; x < mapWidth; x++) {
            const valueIndex = y * mapWidth + x;
            const normalizedValue = (values[valueIndex] - minNoiseHeight) / range;
            const color = getTerrainColor(normalizedValue, thresholds);
            const pixelIndex = valueIndex * 4;

            imageData.data[pixelIndex] = color[0];
            imageData.data[pixelIndex + 1] = color[1];
            imageData.data[pixelIndex + 2] = color[2];
            imageData.data[pixelIndex + 3] = 255;
        }
    }

    const tempCanvas = document.createElement("canvas");
    tempCanvas.width = mapWidth;
    tempCanvas.height = mapHeight;

    const tempCtx = tempCanvas.getContext("2d");
    tempCtx.putImageData(imageData, 0, 0);

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.imageSmoothingEnabled = false;
    ctx.drawImage(tempCanvas, 0, 0, canvas.width, canvas.height);
}

function updateStep3SliderValues() {
    document.getElementById("scale3Value").textContent = document.getElementById("noiseScale3").value;
    document.getElementById("octaves3Value").textContent = document.getElementById("octaves3").value;
    document.getElementById("persistence3Value").textContent = parseFloat(document.getElementById("persistence3").value).toFixed(2);
    document.getElementById("lacunarity3Value").textContent = parseFloat(document.getElementById("lacunarity3").value).toFixed(2);
    document.getElementById("waterThresholdValue").textContent = parseFloat(document.getElementById("waterThreshold").value).toFixed(2);
    document.getElementById("beachThresholdValue").textContent = parseFloat(document.getElementById("beachThreshold").value).toFixed(2);
    document.getElementById("mountainThresholdValue").textContent = parseFloat(document.getElementById("mountainThreshold").value).toFixed(2);
}

function setupStep3() {
    const scaleInput = document.getElementById("noiseScale3");
    const octavesInput = document.getElementById("octaves3");
    const persistenceInput = document.getElementById("persistence3");
    const lacunarityInput = document.getElementById("lacunarity3");
    const waterInput = document.getElementById("waterThreshold");
    const beachInput = document.getElementById("beachThreshold");
    const mountainInput = document.getElementById("mountainThreshold");
    const button = document.getElementById("generateNoiseButton3");

    if (
        !scaleInput ||
        !octavesInput ||
        !persistenceInput ||
        !lacunarityInput ||
        !waterInput ||
        !beachInput ||
        !mountainInput ||
        !button
    ) {
        return;
    }

    const inputs = [
        scaleInput,
        octavesInput,
        persistenceInput,
        lacunarityInput,
        waterInput,
        beachInput,
        mountainInput
    ];

    inputs.forEach(input => {
        input.addEventListener("input", () => {
            updateStep3SliderValues();
            drawTerrainMap();
        });
    });

    button.addEventListener("click", drawTerrainMap);

    updateStep3SliderValues();
    drawTerrainMap();
}

window.addEventListener("stepsLoaded", setupStep3);