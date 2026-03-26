class PerlinNoise {
    constructor() {
        this.permutation = [
            151, 160, 137, 91, 90, 15,
            131, 13, 201, 95, 96, 53, 194, 233, 7, 225,
            140, 36, 103, 30, 69, 142, 8, 99, 37, 240,
            21, 10, 23, 190, 6, 148, 247, 120, 234, 75,
            0, 26, 197, 62, 94, 252, 219, 203, 117, 35,
            11, 32, 57, 177, 33, 88, 237, 149, 56, 87,
            174, 20, 125, 136, 171, 168, 68, 175, 74, 165,
            71, 134, 139, 48, 27, 166, 77, 146, 158, 231,
            83, 111, 229, 122, 60, 211, 133, 230, 220, 105,
            92, 41, 55, 46, 245, 40, 244, 102, 143, 54,
            65, 25, 63, 161, 1, 216, 80, 73, 209, 76,
            132, 187, 208, 89, 18, 169, 200, 196, 135, 130,
            116, 188, 159, 86, 164, 100, 109, 198, 173, 186,
            3, 64, 52, 217, 226, 250, 124, 123, 5, 202,
            38, 147, 118, 126, 255, 82, 85, 212, 207, 206,
            59, 227, 47, 16, 58, 17, 182, 189, 28, 42,
            223, 183, 170, 213, 119, 248, 152, 2, 44, 154,
            163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
            129, 22, 39, 253, 19, 98, 108, 110, 79, 113,
            224, 232, 178, 185, 112, 104, 218, 246, 97, 228,
            251, 34, 242, 193, 238, 210, 144, 12, 191, 179,
            162, 241, 81, 51, 145, 235, 249, 14, 239, 107,
            49, 192, 214, 31, 181, 199, 106, 157, 184, 84,
            204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
            138, 236, 205, 93, 222, 114, 67, 29, 24, 72,
            243, 141, 128, 195, 78, 66, 215, 61, 156, 180
        ];

        this.p = new Array(512);
        for (let i = 0; i < 512; i++) {
            this.p[i] = this.permutation[i % 256];
        }
    }

    fade(t) {
        return t * t * t * (t * (t * 6 - 15) + 10);
    }

    lerp(t, a, b) {
        return a + t * (b - a);
    }

    grad(hash, x, y) {
        const h = hash & 7;
        const u = h < 4 ? x : y;
        const v = h < 4 ? y : x;
        return ((h & 1) === 0 ? u : -u) + ((h & 2) === 0 ? v : -v);
    }

    noise(x, y) {
        const xi = Math.floor(x) & 255;
        const yi = Math.floor(y) & 255;

        const xf = x - Math.floor(x);
        const yf = y - Math.floor(y);

        const u = this.fade(xf);
        const v = this.fade(yf);

        const aa = this.p[this.p[xi] + yi];
        const ab = this.p[this.p[xi] + yi + 1];
        const ba = this.p[this.p[xi + 1] + yi];
        const bb = this.p[this.p[xi + 1] + yi + 1];

        const x1 = this.lerp(u, this.grad(aa, xf, yf), this.grad(ba, xf - 1, yf));
        const x2 = this.lerp(u, this.grad(ab, xf, yf - 1), this.grad(bb, xf - 1, yf - 1));

        return (this.lerp(v, x1, x2) + 1) / 2;
    }
}

const perlin = new PerlinNoise();

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
    const noiseScale = Math.max(0.0001, parseFloat(scaleInput.value) || 1);

    const ctx = canvas.getContext("2d");
    const imageData = ctx.createImageData(mapWidth, mapHeight);

    for (let y = 0; y < mapHeight; y++) {
        for (let x = 0; x < mapWidth; x++) {
            const sampleX = x / noiseScale;
            const sampleY = y / noiseScale;

            const value = perlin.noise(sampleX, sampleY);
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