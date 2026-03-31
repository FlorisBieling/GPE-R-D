function generateAdvancedNoise(x, y, settings) {
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

function drawAdvancedNoiseMap() {
    const scaleInput = document.getElementById("noiseScale2");
    const octavesInput = document.getElementById("octaves");
    const persistenceInput = document.getElementById("persistence");
    const lacunarityInput = document.getElementById("lacunarity");
    const canvas = document.getElementById("noiseCanvas2");

    if (!scaleInput || !octavesInput || !persistenceInput || !lacunarityInput || !canvas || typeof noise === "undefined") {
        return;
    }

    const mapWidth = 200;
    const mapHeight = 200;

    const settings = {
        scale: Math.max(0.0001, parseFloat(scaleInput.value) || 1),
        octaves: parseInt(octavesInput.value, 10) || 1,
        persistence: parseFloat(persistenceInput.value) || 0.5,
        lacunarity: parseFloat(lacunarityInput.value) || 2,
        halfWidth: mapWidth / 2,
        halfHeight: mapHeight / 2
    };

    const ctx = canvas.getContext("2d");
    const imageData = ctx.createImageData(mapWidth, mapHeight);

    const values = new Array(mapWidth * mapHeight);
    let minNoiseHeight = Infinity;
    let maxNoiseHeight = -Infinity;

    for (let y = 0; y < mapHeight; y++) {
        for (let x = 0; x < mapWidth; x++) {
            const noiseHeight = generateAdvancedNoise(x, y, settings);
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
            const color = Math.floor(normalizedValue * 255);
            const pixelIndex = valueIndex * 4;

            imageData.data[pixelIndex] = color;
            imageData.data[pixelIndex + 1] = color;
            imageData.data[pixelIndex + 2] = color;
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

function updateStep2SliderValues() {
    document.getElementById("scale2Value").textContent = document.getElementById("noiseScale2").value;
    document.getElementById("octavesValue").textContent = document.getElementById("octaves").value;
    document.getElementById("persistenceValue").textContent = parseFloat(document.getElementById("persistence").value).toFixed(2);
    document.getElementById("lacunarityValue").textContent = parseFloat(document.getElementById("lacunarity").value).toFixed(2);
}

function setupStep2() {
    const scaleInput = document.getElementById("noiseScale2");
    const octavesInput = document.getElementById("octaves");
    const persistenceInput = document.getElementById("persistence");
    const lacunarityInput = document.getElementById("lacunarity");
    const button = document.getElementById("generateNoiseButton2");

    if (!scaleInput || !octavesInput || !persistenceInput || !lacunarityInput || !button) {
        return;
    }

    const inputs = [scaleInput, octavesInput, persistenceInput, lacunarityInput];

    inputs.forEach(input => {
        input.addEventListener("input", () => {
            updateStep2SliderValues();
            drawAdvancedNoiseMap();
        });
    });

    button.addEventListener("click", drawAdvancedNoiseMap);

    updateStep2SliderValues();
    drawAdvancedNoiseMap();
}

window.addEventListener("stepsLoaded", setupStep2);