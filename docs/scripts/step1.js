function pseudoNoise(x, y, scale) {
    const value =
        Math.sin(x / scale * 2.31) +
        Math.cos(y / scale * 1.73) +
        Math.sin((x + y) / scale * 1.17);

    return (value + 3) / 6;
}

function drawNoiseMap() {
    const widthInput = document.getElementById("mapWidth");
    const heightInput = document.getElementById("mapHeight");
    const scaleInput = document.getElementById("noiseScale");
    const canvas = document.getElementById("noiseCanvas");

    if (!widthInput || !heightInput || !scaleInput || !canvas) {
        return;
    }

    const mapWidth = Math.max(1, parseInt(widthInput.value, 10) || 1);
    const mapHeight = Math.max(1, parseInt(heightInput.value, 10) || 1);
    const noiseScale = Math.max(1, parseFloat(scaleInput.value) || 1);

    const ctx = canvas.getContext("2d");
    const imageData = ctx.createImageData(mapWidth, mapHeight);

    for (let y = 0; y < mapHeight; y++) {
        for (let x = 0; x < mapWidth; x++) {
            const value = pseudoNoise(x, y, noiseScale);
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

    if (!button || !widthInput || !heightInput || !scaleInput) {
        return;
    }

    button.addEventListener("click", drawNoiseMap);
    widthInput.addEventListener("input", drawNoiseMap);
    heightInput.addEventListener("input", drawNoiseMap);
    scaleInput.addEventListener("input", drawNoiseMap);

    drawNoiseMap();
}

window.addEventListener("stepsLoaded", setupStep1);