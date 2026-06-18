using UnityEngine;

public sealed class BiomeControlMapGenerator
{
    const int TextureCount = 7;

    readonly BiomeType[] biomes;
    readonly BiomeGenerator biomeGenerator;
    readonly float blendSoftness;
    readonly float boundaryNoiseScale;
    readonly float boundaryNoiseHeightInfluence;
    readonly float patchNoiseScale;
    readonly float patchNoiseStrength;
    readonly Vector2 blendNoiseOffset;
    readonly bool useSnowMask;
    readonly float snowStartHeight;
    readonly float snowEndHeight;
    readonly float snowLineNoiseScale;
    readonly float snowLineNoiseHeightInfluence;
    readonly float snowHoleNoiseScale;
    readonly float snowHoleStrength;
    readonly float snowHoleThreshold;
    readonly Vector2 snowNoiseOffset;

    public BiomeControlMapGenerator(MapGenerator settings, BiomeGenerator biomeGenerator)
    {
        biomes = settings.biomes;
        this.biomeGenerator = biomeGenerator;
        blendSoftness = settings.biomeBlendSoftness;
        boundaryNoiseScale = settings.biomeBoundaryNoiseScale;
        boundaryNoiseHeightInfluence = settings.biomeBoundaryNoiseHeightInfluence;
        patchNoiseScale = settings.biomePatchNoiseScale;
        patchNoiseStrength = settings.biomePatchNoiseStrength;
        blendNoiseOffset = settings.biomeBlendNoiseOffset;
        useSnowMask = settings.useSnowMask;
        snowStartHeight = settings.snowStartHeight;
        snowEndHeight = settings.snowEndHeight;
        snowLineNoiseScale = settings.snowLineNoiseScale;
        snowLineNoiseHeightInfluence = settings.snowLineNoiseHeightInfluence;
        snowHoleNoiseScale = settings.snowHoleNoiseScale;
        snowHoleStrength = settings.snowHoleStrength;
        snowHoleThreshold = settings.snowHoleThreshold;
        snowNoiseOffset = settings.snowNoiseOffset;
    }

    public void Generate(float[,] heightMap, float[,] temperatureMap, float[,] moistureMap, Vector2 centre, out Color[] controlMapA, out Color[] controlMapB)
    {
        int size = heightMap.GetLength(0);
        controlMapA = new Color[size * size];
        controlMapB = new Color[size * size];
        float halfSize = (size - 1) / 2f;

        for (int y = 0; y < size; y++)
        {
            for (int x = 0; x < size; x++)
            {
                float worldX = centre.x + x - halfSize;
                float worldZ = centre.y + halfSize - y;
                float[] weights = GetWeights(heightMap[x, y], temperatureMap[x, y], moistureMap[x, y], worldX, worldZ);
                int index = y * size + x;
                controlMapA[index] = new Color(weights[0], weights[1], weights[2], weights[3]);
                controlMapB[index] = new Color(weights[4], weights[5], weights[6], 0f);
            }
        }
    }

    float[] GetWeights(float height, float temperature, float moisture, float worldX, float worldZ)
    {
        float[] weights = new float[TextureCount];
        int selectedBiomeIndex = biomeGenerator.GetBiomeIndex(height, temperature, moisture);

        if (selectedBiomeIndex < 0)
        {
            weights[2] = 1f;
            return weights;
        }

        BiomeTextureType selectedType = ResolveTextureType(biomes[selectedBiomeIndex]);
        if (selectedType == BiomeTextureType.Water)
        {
            weights[0] = 1f;
            return weights;
        }

        float boundaryNoise = Mathf.PerlinNoise(
            (worldX + blendNoiseOffset.x) / Mathf.Max(0.0001f, boundaryNoiseScale),
            (worldZ + blendNoiseOffset.y) / Mathf.Max(0.0001f, boundaryNoiseScale)
        );
        float noisyHeight = Mathf.Clamp01(height + (boundaryNoise - 0.5f) * boundaryNoiseHeightInfluence * 2f);
        float softness = Mathf.Max(0.0001f, blendSoftness);
        float totalWeight = 0f;

        for (int i = 0; i < biomes.Length; i++)
        {
            BiomeTextureType type = ResolveTextureType(biomes[i]);
            int weightIndex = GetTextureWeightIndex(type);
            if (type == BiomeTextureType.Auto || type == BiomeTextureType.Water || weightIndex < 0)
            {
                continue;
            }

            BiomeType biome = biomes[i];
            float weight = SmoothRangeWeight(noisyHeight, biome.minHeight, biome.maxHeight, softness)
                * SmoothRangeWeight(temperature, biome.minTemperature, biome.maxTemperature, softness)
                * SmoothRangeWeight(moisture, biome.minMoisture, biome.maxMoisture, softness);

            float patchNoise = Mathf.PerlinNoise(
                (worldX + blendNoiseOffset.x + i * 37.19f) / Mathf.Max(0.0001f, patchNoiseScale),
                (worldZ + blendNoiseOffset.y + i * 71.43f) / Mathf.Max(0.0001f, patchNoiseScale)
            );
            weight *= Mathf.Lerp(1f, Mathf.Lerp(0.65f, 1.35f, patchNoise), patchNoiseStrength);
            weights[weightIndex] += weight;
            totalWeight += weight;
        }

        if (totalWeight <= 0.0001f)
        {
            int fallbackIndex = GetTextureWeightIndex(selectedType);
            weights[fallbackIndex >= 0 ? fallbackIndex : 2] = 1f;
        }
        else
        {
            for (int i = 0; i < weights.Length; i++) weights[i] /= totalWeight;
        }

        float snowAmount = GetSnowAmount(height, worldX, worldZ);
        if (snowAmount > 0f)
        {
            for (int i = 1; i < weights.Length; i++)
            {
                if (i != 6) weights[i] *= 1f - snowAmount;
            }
            weights[6] = Mathf.Max(weights[6], snowAmount);
        }

        Normalize(weights);
        return weights;
    }

    float GetSnowAmount(float height, float worldX, float worldZ)
    {
        if (!useSnowMask) return 0f;

        float start = Mathf.Min(snowStartHeight, snowEndHeight);
        float end = Mathf.Max(snowStartHeight, snowEndHeight);
        float transition = Mathf.Max(0.0001f, end - start);
        float lineNoise = Mathf.PerlinNoise(
            (worldX + snowNoiseOffset.x) / Mathf.Max(0.0001f, snowLineNoiseScale),
            (worldZ + snowNoiseOffset.y) / Mathf.Max(0.0001f, snowLineNoiseScale)
        );
        float localStart = start + (lineNoise - 0.5f) * snowLineNoiseHeightInfluence * 2f;
        float amount = Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(localStart, localStart + transition, height));
        float holeNoise = Mathf.PerlinNoise(
            (worldX + snowNoiseOffset.x + 913.2f) / Mathf.Max(0.0001f, snowHoleNoiseScale),
            (worldZ + snowNoiseOffset.y + 281.7f) / Mathf.Max(0.0001f, snowHoleNoiseScale)
        );
        float holeAmount = Mathf.SmoothStep(snowHoleThreshold, 1f, holeNoise) * snowHoleStrength;
        return Mathf.Clamp01(amount - holeAmount * (1f - Mathf.SmoothStep(end, 1f, height)));
    }

    static float SmoothRangeWeight(float value, float min, float max, float softness)
    {
        float fromMin = Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(min - softness, min + softness, value));
        float fromMax = 1f - Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(max - softness, max + softness, value));
        return Mathf.Clamp01(fromMin * fromMax);
    }

    static void Normalize(float[] weights)
    {
        float total = 0f;
        for (int i = 0; i < weights.Length; i++) total += weights[i];
        if (total <= 0.0001f)
        {
            weights[2] = 1f;
            return;
        }
        for (int i = 0; i < weights.Length; i++) weights[i] /= total;
    }

    static int GetTextureWeightIndex(BiomeTextureType type)
    {
        switch (type)
        {
            case BiomeTextureType.Water: return 0;
            case BiomeTextureType.Beach: return 1;
            case BiomeTextureType.Plains: return 2;
            case BiomeTextureType.Forest: return 3;
            case BiomeTextureType.Desert: return 4;
            case BiomeTextureType.Mountain: return 5;
            case BiomeTextureType.Snow: return 6;
            default: return -1;
        }
    }

    static BiomeTextureType ResolveTextureType(BiomeType biome)
    {
        if (biome.textureType != BiomeTextureType.Auto) return biome.textureType;
        string name = string.IsNullOrWhiteSpace(biome.name) ? string.Empty : biome.name.ToLowerInvariant();
        if (name.Contains("water") || name.Contains("ocean") || name.Contains("sea") || name.Contains("lake")) return BiomeTextureType.Water;
        if (name.Contains("beach") || name.Contains("sand shore") || name.Contains("shore")) return BiomeTextureType.Beach;
        if (name.Contains("plain") || name.Contains("grass") || name.Contains("field")) return BiomeTextureType.Plains;
        if (name.Contains("forest") || name.Contains("woods")) return BiomeTextureType.Forest;
        if (name.Contains("desert") || name.Contains("dune")) return BiomeTextureType.Desert;
        if (name.Contains("mountain") || name.Contains("rock")) return BiomeTextureType.Mountain;
        if (name.Contains("snow") || name.Contains("ice")) return BiomeTextureType.Snow;
        return BiomeTextureType.Plains;
    }
}
