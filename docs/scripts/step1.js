function drawNoiseMap() {
    const widthInput = document.getElementById("mapWidth");
    const heightInput = document.getElementById("mapHeight");
    const scaleInput = document.getElementById("noiseScale");
    const seedInput = document.getElementById("noiseSeed");
    const canvas = document.getElementById("noiseCanvas");

    if (!widthInput || !heightInput || !scaleInput || !seedInput || !canvas || typeof noise === "undefined") {
        return;
    }

    const mapWidth = Math.max(1, parseInt(widthInput.value, 10) || 1);
    const mapHeight = Math.max(1, parseInt(heightInput.value, 10) || 1);
    const noiseScale = Math.max(0.0001, parseFloat(scaleInput.value) || 1);
    const seed = parseInt(seedInput.value, 10) || 0;

    noise.seed(seed);

    const ctx = canvas.getContext("2d");
    const imageData = ctx.createImageData(mapWidth, mapHeight);

    for (let y = 0; y < mapHeight; y++) {
        for (let x = 0; x < mapWidth; x++) {
            const sampleX = x / noiseScale;
            const sampleY = y / noiseScale;

            let value = noise.perlin2(sampleX, sampleY);

            value = (value + 1) / 2;
            value = Math.max(0, Math.min(1, value));

            const color = Math.floor(value * 255);
            const index = (y * mapWidth + x) * 4;

            imageData.data[index] = color;
            imageData.data[index + 1] = color;
            imageData.data[index + 2] = color;
            imageData.data[index + 3] = 255;
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

function setupStep1() {
    const button = document.getElementById("generateNoiseButton");
    const widthInput = document.getElementById("mapWidth");
    const heightInput = document.getElementById("mapHeight");
    const scaleInput = document.getElementById("noiseScale");
    const seedInput = document.getElementById("noiseSeed");

    if (!button || !widthInput || !heightInput || !scaleInput || !seedInput) {
        return;
    }

    button.addEventListener("click", drawNoiseMap);
    widthInput.addEventListener("input", drawNoiseMap);
    heightInput.addEventListener("input", drawNoiseMap);
    scaleInput.addEventListener("input", drawNoiseMap);
    seedInput.addEventListener("input", drawNoiseMap);

    drawNoiseMap();
}

window.addEventListener("stepsLoaded", setupStep1);