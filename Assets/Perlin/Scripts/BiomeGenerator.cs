using UnityEngine;

public sealed class BiomeGenerator
{
    readonly BiomeType[] biomes;
    readonly int mapSize;
    readonly int smoothRadius;
    readonly float smoothStrength;

    public BiomeGenerator(BiomeType[] biomes, int mapSize, int smoothRadius, float smoothStrength)
    {
        this.biomes = biomes;
        this.mapSize = mapSize;
        this.smoothRadius = smoothRadius;
        this.smoothStrength = smoothStrength;
    }

    public int GetBiomeIndex(float height, float temperature, float moisture)
    {
        if (biomes == null || biomes.Length == 0)
        {
            return -1;
        }

        int selectedIndex = -1;
        int bestPriority = int.MinValue;

        for (int i = 0; i < biomes.Length; i++)
        {
            BiomeType biome = biomes[i];
            bool matches = height >= biome.minHeight && height <= biome.maxHeight
                && temperature >= biome.minTemperature && temperature <= biome.maxTemperature
                && moisture >= biome.minMoisture && moisture <= biome.maxMoisture;

            if (matches && (selectedIndex == -1 || biome.priority > bestPriority))
            {
                selectedIndex = i;
                bestPriority = biome.priority;
            }
        }

        return selectedIndex != -1 ? selectedIndex : GetClosestBiomeIndex(height, temperature, moisture);
    }

    public BiomeType GetBiome(float height, float temperature, float moisture)
    {
        int index = GetBiomeIndex(height, temperature, moisture);
        return index >= 0 ? biomes[index] : default;
    }

    public Color[] GenerateColorMap(float[,] heightMap, float[,] temperatureMap, float[,] moistureMap)
    {
        Color[] baseColors = new Color[mapSize * mapSize];
        int[] biomeIndices = new int[mapSize * mapSize];

        for (int y = 0; y < mapSize; y++)
        {
            for (int x = 0; x < mapSize; x++)
            {
                int index = y * mapSize + x;
                int biomeIndex = GetBiomeIndex(heightMap[x, y], temperatureMap[x, y], moistureMap[x, y]);
                biomeIndices[index] = biomeIndex;
                baseColors[index] = biomeIndex >= 0 ? biomes[biomeIndex].color : Color.magenta;
            }
        }

        if (smoothRadius <= 0 || smoothStrength <= 0f)
        {
            return baseColors;
        }

        return SmoothColorMap(baseColors, biomeIndices);
    }

    int GetClosestBiomeIndex(float height, float temperature, float moisture)
    {
        int closestIndex = 0;
        float bestScore = float.MaxValue;

        for (int i = 0; i < biomes.Length; i++)
        {
            BiomeType biome = biomes[i];
            float score = GetRangeDistance(height, biome.minHeight, biome.maxHeight)
                + GetRangeDistance(temperature, biome.minTemperature, biome.maxTemperature)
                + GetRangeDistance(moisture, biome.minMoisture, biome.maxMoisture);

            if (score < bestScore)
            {
                bestScore = score;
                closestIndex = i;
            }
        }

        return closestIndex;
    }

    Color[] SmoothColorMap(Color[] original, int[] biomeIndices)
    {
        Color[] result = new Color[original.Length];

        for (int y = 0; y < mapSize; y++)
        {
            for (int x = 0; x < mapSize; x++)
            {
                int index = y * mapSize + x;
                int currentIndex = biomeIndices[index];

                if (currentIndex < 0 || !biomes[currentIndex].allowColorBlend)
                {
                    result[index] = original[index];
                    continue;
                }

                Color average = Color.black;
                float totalWeight = 0f;
                bool hasDifferentNeighbor = false;

                for (int offsetY = -smoothRadius; offsetY <= smoothRadius; offsetY++)
                {
                    for (int offsetX = -smoothRadius; offsetX <= smoothRadius; offsetX++)
                    {
                        int sampleX = Mathf.Clamp(x + offsetX, 0, mapSize - 1);
                        int sampleY = Mathf.Clamp(y + offsetY, 0, mapSize - 1);
                        int sampleIndex = sampleY * mapSize + sampleX;
                        int neighborIndex = biomeIndices[sampleIndex];

                        if (neighborIndex < 0 || !biomes[neighborIndex].allowColorBlend)
                        {
                            continue;
                        }

                        hasDifferentNeighbor |= neighborIndex != currentIndex;
                        float distance = Mathf.Sqrt(offsetX * offsetX + offsetY * offsetY);
                        float weight = 1f / (1f + distance);
                        average += original[sampleIndex] * weight;
                        totalWeight += weight;
                    }
                }

                result[index] = !hasDifferentNeighbor || totalWeight <= 0f
                    ? original[index]
                    : Color.Lerp(original[index], average / totalWeight, smoothStrength);
            }
        }

        return result;
    }

    static float GetRangeDistance(float value, float min, float max)
    {
        if (value < min) return min - value;
        if (value > max) return value - max;
        return 0f;
    }
}
