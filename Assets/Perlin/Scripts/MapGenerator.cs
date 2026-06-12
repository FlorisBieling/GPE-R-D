using System;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;

public class MapGenerator : MonoBehaviour
{
    public enum DrawMode { HeightNoiseMap, TemperatureNoiseMap, MoistureNoiseMap, ColorMap, BiomeControlMapA, BiomeControlMapB, Mesh }
    public DrawMode drawMode;

    public Noise.NormalizeMode normalizeMode;

    public const int mapChunkSize = 241;

    [Range(0, 6)]
    public int editorPreviewLOD;

    public float noiseScale;
    public int octaves;

    [Range(0, 1)]
    public float persistance;

    public float lacunarity;
    public int seed;

    [Range(0, 10)]
    public float redistributionPower;

    public Vector2 offset;

    public float meshHeightMultiplier;
    public AnimationCurve meshHeightCurve;

    public bool autoUpdate;

    [Header("Biome Color Smoothing")]
    [Range(0, 3)]
    public int biomeColorSmoothRadius = 1;

    [Range(0f, 1f)]
    public float biomeColorSmoothStrength = 0.25f;

    [Header("Climate Maps")]
    public float temperatureNoiseScaleMultiplier = 5f;
    public Vector2 temperatureOffset;

    public float moistureNoiseScaleMultiplier = 6f;
    public Vector2 moistureOffset;

    [Header("Biome Texture Blending")]
    [Range(0f, 0.5f)]
    public float biomeBlendSoftness = 0.08f;

    public float biomeBoundaryNoiseScale = 65f;

    [Range(0f, 0.25f)]
    public float biomeBoundaryNoiseHeightInfluence = 0.045f;

    public float biomePatchNoiseScale = 45f;

    [Range(0f, 1f)]
    public float biomePatchNoiseStrength = 0.25f;

    public Vector2 biomeBlendNoiseOffset;

    [Header("Snow Texture Blend")]
    public bool useSnowMask = true;

    [Range(0f, 1f)]
    public float snowStartHeight = 0.75f;

    [Range(0f, 1f)]
    public float snowEndHeight = 0.85f;

    public float snowLineNoiseScale = 70f;

    [Range(0f, 0.25f)]
    public float snowLineNoiseHeightInfluence = 0.08f;

    public float snowHoleNoiseScale = 25f;

    [Range(0f, 1f)]
    public float snowHoleStrength = 0.25f;

    [Range(0f, 1f)]
    public float snowHoleThreshold = 0.45f;

    public Vector2 snowNoiseOffset;

    [Header("Biomes")]
    public BiomeType[] biomes;

    Queue<MapThreadInfo<MapData>> mapDataThreadInfoQueue = new Queue<MapThreadInfo<MapData>>();
    Queue<MapThreadInfo<MeshData>> meshDataThreadInfoQueue = new Queue<MapThreadInfo<MeshData>>();
    Queue<MapThreadInfo<DecorationSpawnData[]>> decorationThreadInfoQueue = new Queue<MapThreadInfo<DecorationSpawnData[]>>();

    public void DrawMapInEditor()
    {
        MapData mapData = GenerateMapData(Vector2.zero);
        MapDisplay display = FindObjectOfType<MapDisplay>();

        if (drawMode == DrawMode.HeightNoiseMap)
        {
            display.DrawMesh(
                MeshGenerator.GenerateTerrainMesh(mapData.heightMap, meshHeightMultiplier, meshHeightCurve, editorPreviewLOD),
                TextureGenerator.TextureFromHeightMap(mapData.heightMap)
            );
        }
        else if (drawMode == DrawMode.TemperatureNoiseMap)
        {
            display.DrawMesh(
                MeshGenerator.GenerateTerrainMesh(mapData.temperatureMap, meshHeightMultiplier, meshHeightCurve, editorPreviewLOD, true),
                TextureGenerator.TextureFromHeightMap(mapData.temperatureMap)
            );
        }
        else if (drawMode == DrawMode.MoistureNoiseMap)
        {
            display.DrawMesh(
                MeshGenerator.GenerateTerrainMesh(mapData.moistureMap, meshHeightMultiplier, meshHeightCurve, editorPreviewLOD, true),
                TextureGenerator.TextureFromHeightMap(mapData.moistureMap)
            );
        }
        else if (drawMode == DrawMode.ColorMap)
        {
            display.DrawTexture(TextureGenerator.TextureFromColorMap(mapData.colorMap, mapChunkSize, mapChunkSize));
        }
        else if (drawMode == DrawMode.BiomeControlMapA)
        {
            display.DrawTexture(TextureGenerator.TextureFromColorMap(mapData.biomeControlMapA, mapChunkSize, mapChunkSize));
        }
        else if (drawMode == DrawMode.BiomeControlMapB)
        {
            display.DrawTexture(TextureGenerator.TextureFromColorMap(mapData.biomeControlMapB, mapChunkSize, mapChunkSize));
        }
        else if (drawMode == DrawMode.Mesh)
        {
            display.DrawMesh(
                MeshGenerator.GenerateTerrainMesh(mapData.heightMap, meshHeightMultiplier, meshHeightCurve, editorPreviewLOD),
                TextureGenerator.TextureFromColorMap(mapData.colorMap, mapChunkSize, mapChunkSize),
                TextureGenerator.TextureFromColorMap(mapData.biomeControlMapA, mapChunkSize, mapChunkSize),
                TextureGenerator.TextureFromColorMap(mapData.biomeControlMapB, mapChunkSize, mapChunkSize)
            );
        }
    }

    public void RequestMapData(Vector2 centre, Action<MapData> callback)
    {
        ThreadStart threadStart = delegate
        {
            MapDataThread(centre, callback);
        };

        new Thread(threadStart).Start();
    }

    void MapDataThread(Vector2 centre, Action<MapData> callback)
    {
        MapData mapData = GenerateMapData(centre);

        lock (mapDataThreadInfoQueue)
        {
            mapDataThreadInfoQueue.Enqueue(new MapThreadInfo<MapData>(callback, mapData));
        }
    }

    public void RequestMeshData(MapData mapData, int lod, Action<MeshData> callback)
    {
        ThreadStart threadStart = delegate
        {
            MeshDataThread(mapData, lod, callback);
        };

        new Thread(threadStart).Start();
    }

    void MeshDataThread(MapData mapData, int lod, Action<MeshData> callback)
    {
        MeshData meshData = MeshGenerator.GenerateTerrainMesh(mapData.heightMap, meshHeightMultiplier, meshHeightCurve, lod);

        lock (meshDataThreadInfoQueue)
        {
            meshDataThreadInfoQueue.Enqueue(new MapThreadInfo<MeshData>(callback, meshData));
        }
    }

    public void RequestDecorationData(MapData mapData, Vector2 chunkPosition, Action<DecorationSpawnData[]> callback)
    {
        ThreadStart threadStart = delegate
        {
            DecorationDataThread(mapData, chunkPosition, callback);
        };

        new Thread(threadStart).Start();
    }

    void DecorationDataThread(MapData mapData, Vector2 chunkPosition, Action<DecorationSpawnData[]> callback)
    {
        DecorationSpawnData[] decorationData = GenerateDecorationData(mapData, chunkPosition);

        lock (decorationThreadInfoQueue)
        {
            decorationThreadInfoQueue.Enqueue(new MapThreadInfo<DecorationSpawnData[]>(callback, decorationData));
        }
    }

    void Update()
    {
        lock (mapDataThreadInfoQueue)
        {
            while (mapDataThreadInfoQueue.Count > 0)
            {
                MapThreadInfo<MapData> threadInfo = mapDataThreadInfoQueue.Dequeue();
                threadInfo.callback(threadInfo.parameter);
            }
        }

        lock (meshDataThreadInfoQueue)
        {
            while (meshDataThreadInfoQueue.Count > 0)
            {
                MapThreadInfo<MeshData> threadInfo = meshDataThreadInfoQueue.Dequeue();
                threadInfo.callback(threadInfo.parameter);
            }
        }

        lock (decorationThreadInfoQueue)
        {
            while (decorationThreadInfoQueue.Count > 0)
            {
                MapThreadInfo<DecorationSpawnData[]> threadInfo = decorationThreadInfoQueue.Dequeue();
                threadInfo.callback(threadInfo.parameter);
            }
        }
    }

    public float GetMeshHeight(float heightValue)
    {
        return meshHeightCurve.Evaluate(heightValue) * meshHeightMultiplier;
    }

    public MapData GetMapData(Vector2 centre)
    {
        return GenerateMapData(centre);
    }

    MapData GenerateMapData(Vector2 centre)
    {
        float[,] heightMap = Noise.GenerateNoiseMap(
            mapChunkSize,
            mapChunkSize,
            seed,
            noiseScale,
            octaves,
            persistance,
            lacunarity,
            centre + offset,
            normalizeMode
        );

        float[,] temperatureMap = Noise.GenerateNoiseMap(
            mapChunkSize,
            mapChunkSize,
            seed + 2,
            Mathf.Max(0.0001f, noiseScale * temperatureNoiseScaleMultiplier),
            octaves,
            persistance,
            lacunarity,
            centre + offset + temperatureOffset,
            normalizeMode
        );

        float[,] moistureMap = Noise.GenerateNoiseMap(
            mapChunkSize,
            mapChunkSize,
            seed + 4,
            Mathf.Max(0.0001f, noiseScale * moistureNoiseScaleMultiplier),
            octaves,
            persistance,
            lacunarity,
            centre + offset + moistureOffset,
            normalizeMode
        );

        GenerateTextureMaps(heightMap, temperatureMap, moistureMap, centre, out Color[] colorMap, out Color[] biomeControlMapA, out Color[] biomeControlMapB);

        return new MapData(heightMap, temperatureMap, moistureMap, colorMap, biomeControlMapA, biomeControlMapB);
    }

    void GenerateTextureMaps(float[,] heightMap, float[,] temperatureMap, float[,] moistureMap, Vector2 centre, out Color[] colorMap, out Color[] biomeControlMapA, out Color[] biomeControlMapB)
    {
        colorMap = CombineMaps(heightMap, temperatureMap, moistureMap);
        biomeControlMapA = new Color[mapChunkSize * mapChunkSize];
        biomeControlMapB = new Color[mapChunkSize * mapChunkSize];

        float halfSize = (mapChunkSize - 1) / 2f;

        for (int y = 0; y < mapChunkSize; y++)
        {
            for (int x = 0; x < mapChunkSize; x++)
            {
                float worldX = centre.x + x - halfSize;
                float worldZ = centre.y + halfSize - y;
                float currentHeight = heightMap[x, y];
                float currentTemperature = temperatureMap[x, y];
                float currentMoisture = moistureMap[x, y];

                float[] weights = GetBiomeTextureWeights(currentHeight, currentTemperature, currentMoisture, worldX, worldZ);
                int index = y * mapChunkSize + x;

                biomeControlMapA[index] = new Color(weights[0], weights[1], weights[2], weights[3]);
                biomeControlMapB[index] = new Color(weights[4], weights[5], weights[6], 0f);
            }
        }
    }

    float[] GetBiomeTextureWeights(float currentHeight, float currentTemperature, float currentMoisture, float worldX, float worldZ)
    {
        float[] weights = new float[7];

        int selectedBiomeIndex = GetBiomeIndex(currentHeight, currentTemperature, currentMoisture);
        BiomeTextureType selectedType = ResolveBiomeTextureType(biomes[selectedBiomeIndex]);

        if (selectedType == BiomeTextureType.Water)
        {
            weights[0] = 1f;
            return weights;
        }

        float boundaryNoiseScale = Mathf.Max(0.0001f, biomeBoundaryNoiseScale);
        float boundaryNoise = Mathf.PerlinNoise(
            (worldX + biomeBlendNoiseOffset.x) / boundaryNoiseScale,
            (worldZ + biomeBlendNoiseOffset.y) / boundaryNoiseScale
        );

        float noisyHeight = Mathf.Clamp01(currentHeight + (boundaryNoise - 0.5f) * biomeBoundaryNoiseHeightInfluence * 2f);
        float softness = Mathf.Max(0.0001f, biomeBlendSoftness);
        float totalWeight = 0f;

        for (int i = 0; i < biomes.Length; i++)
        {
            BiomeTextureType type = ResolveBiomeTextureType(biomes[i]);

            if (type == BiomeTextureType.Auto || type == BiomeTextureType.Water)
            {
                continue;
            }

            int weightIndex = GetTextureWeightIndex(type);

            if (weightIndex < 0 || weightIndex >= weights.Length)
            {
                continue;
            }

            BiomeType biome = biomes[i];
            float heightWeight = SmoothRangeWeight(noisyHeight, biome.minHeight, biome.maxHeight, softness);
            float temperatureWeight = SmoothRangeWeight(currentTemperature, biome.minTemperature, biome.maxTemperature, softness);
            float moistureWeight = SmoothRangeWeight(currentMoisture, biome.minMoisture, biome.maxMoisture, softness);
            float weight = heightWeight * temperatureWeight * moistureWeight;

            float patchNoiseScale = Mathf.Max(0.0001f, biomePatchNoiseScale);
            float patchNoise = Mathf.PerlinNoise(
                (worldX + biomeBlendNoiseOffset.x + i * 37.19f) / patchNoiseScale,
                (worldZ + biomeBlendNoiseOffset.y + i * 71.43f) / patchNoiseScale
            );

            weight *= Mathf.Lerp(1f, Mathf.Lerp(0.65f, 1.35f, patchNoise), biomePatchNoiseStrength);
            weights[weightIndex] += weight;
            totalWeight += weight;
        }

        if (totalWeight <= 0.0001f)
        {
            int fallbackIndex = GetTextureWeightIndex(selectedType);
            if (fallbackIndex < 0)
            {
                fallbackIndex = 2;
            }
            weights[fallbackIndex] = 1f;
            totalWeight = 1f;
        }
        else
        {
            for (int i = 0; i < weights.Length; i++)
            {
                weights[i] /= totalWeight;
            }
        }

        float snowAmount = GetSnowAmount(currentHeight, worldX, worldZ);

        if (snowAmount > 0f)
        {
            for (int i = 1; i < weights.Length; i++)
            {
                if (i == 6)
                {
                    continue;
                }

                weights[i] *= 1f - snowAmount;
            }

            weights[6] = Mathf.Max(weights[6], snowAmount);
        }

        NormalizeWeights(weights);
        return weights;
    }

    float GetSnowAmount(float currentHeight, float worldX, float worldZ)
    {
        if (!useSnowMask)
        {
            return 0f;
        }

        float startHeight = Mathf.Min(snowStartHeight, snowEndHeight);
        float endHeight = Mathf.Max(snowStartHeight, snowEndHeight);
        float transitionSize = Mathf.Max(0.0001f, endHeight - startHeight);

        float lineScale = Mathf.Max(0.0001f, snowLineNoiseScale);
        float lineNoise = Mathf.PerlinNoise(
            (worldX + snowNoiseOffset.x) / lineScale,
            (worldZ + snowNoiseOffset.y) / lineScale
        );

        float localSnowStart = startHeight + (lineNoise - 0.5f) * snowLineNoiseHeightInfluence * 2f;
        float snowAmount = Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(localSnowStart, localSnowStart + transitionSize, currentHeight));

        float holeScale = Mathf.Max(0.0001f, snowHoleNoiseScale);
        float holeNoise = Mathf.PerlinNoise(
            (worldX + snowNoiseOffset.x + 913.2f) / holeScale,
            (worldZ + snowNoiseOffset.y + 281.7f) / holeScale
        );

        float holeAmount = Mathf.SmoothStep(snowHoleThreshold, 1f, holeNoise) * snowHoleStrength;
        snowAmount = Mathf.Clamp01(snowAmount - holeAmount * (1f - Mathf.SmoothStep(endHeight, 1f, currentHeight)));

        return snowAmount;
    }

    float SmoothRangeWeight(float value, float min, float max, float softness)
    {
        float insideFromMin = Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(min - softness, min + softness, value));
        float insideFromMax = 1f - Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(max - softness, max + softness, value));
        return Mathf.Clamp01(insideFromMin * insideFromMax);
    }

    void NormalizeWeights(float[] weights)
    {
        float total = 0f;

        for (int i = 0; i < weights.Length; i++)
        {
            total += weights[i];
        }

        if (total <= 0.0001f)
        {
            weights[2] = 1f;
            return;
        }

        for (int i = 0; i < weights.Length; i++)
        {
            weights[i] /= total;
        }
    }

    int GetTextureWeightIndex(BiomeTextureType type)
    {
        if (type == BiomeTextureType.Water) return 0;
        if (type == BiomeTextureType.Beach) return 1;
        if (type == BiomeTextureType.Plains) return 2;
        if (type == BiomeTextureType.Forest) return 3;
        if (type == BiomeTextureType.Desert) return 4;
        if (type == BiomeTextureType.Mountain) return 5;
        if (type == BiomeTextureType.Snow) return 6;
        return -1;
    }

    BiomeTextureType ResolveBiomeTextureType(BiomeType biome)
    {
        if (biome.textureType != BiomeTextureType.Auto)
        {
            return biome.textureType;
        }

        string biomeName = string.IsNullOrWhiteSpace(biome.name) ? string.Empty : biome.name.ToLowerInvariant();

        if (biomeName.Contains("water") || biomeName.Contains("ocean") || biomeName.Contains("sea") || biomeName.Contains("lake")) return BiomeTextureType.Water;
        if (biomeName.Contains("beach") || biomeName.Contains("sand shore") || biomeName.Contains("shore")) return BiomeTextureType.Beach;
        if (biomeName.Contains("plain") || biomeName.Contains("grass") || biomeName.Contains("field")) return BiomeTextureType.Plains;
        if (biomeName.Contains("forest") || biomeName.Contains("woods")) return BiomeTextureType.Forest;
        if (biomeName.Contains("desert") || biomeName.Contains("dune")) return BiomeTextureType.Desert;
        if (biomeName.Contains("mountain") || biomeName.Contains("rock")) return BiomeTextureType.Mountain;
        if (biomeName.Contains("snow") || biomeName.Contains("ice")) return BiomeTextureType.Snow;

        return BiomeTextureType.Plains;
    }

    public Color[] CombineMaps(float[,] heightMap, float[,] temperatureMap, float[,] moistureMap)
    {
        Color[] baseColorMap = new Color[mapChunkSize * mapChunkSize];
        int[] biomeIndexMap = new int[mapChunkSize * mapChunkSize];

        for (int y = 0; y < mapChunkSize; y++)
        {
            for (int x = 0; x < mapChunkSize; x++)
            {
                float currentHeight = heightMap[x, y];
                float currentTemperature = temperatureMap[x, y];
                float currentMoisture = moistureMap[x, y];

                int biomeIndex = GetBiomeIndex(currentHeight, currentTemperature, currentMoisture);
                int index = y * mapChunkSize + x;

                biomeIndexMap[index] = biomeIndex;
                baseColorMap[index] = biomes[biomeIndex].color;
            }
        }

        if (biomeColorSmoothRadius <= 0 || biomeColorSmoothStrength <= 0f)
        {
            return baseColorMap;
        }

        return SmoothColorMap(baseColorMap, biomeIndexMap, biomeColorSmoothRadius, biomeColorSmoothStrength);
    }

    public int GetBiomeIndex(float currentHeight, float currentTemperature, float currentMoisture)
    {
        if (biomes == null || biomes.Length == 0)
        {
            return -1;
        }

        int selectedBiomeIndex = -1;
        int bestPriority = int.MinValue;

        for (int i = 0; i < biomes.Length; i++)
        {
            BiomeType biome = biomes[i];

            bool heightMatches = currentHeight >= biome.minHeight && currentHeight <= biome.maxHeight;
            bool temperatureMatches = currentTemperature >= biome.minTemperature && currentTemperature <= biome.maxTemperature;
            bool moistureMatches = currentMoisture >= biome.minMoisture && currentMoisture <= biome.maxMoisture;

            if (!heightMatches || !temperatureMatches || !moistureMatches)
            {
                continue;
            }

            if (selectedBiomeIndex == -1 || biome.priority > bestPriority)
            {
                selectedBiomeIndex = i;
                bestPriority = biome.priority;
            }
        }

        if (selectedBiomeIndex != -1)
        {
            return selectedBiomeIndex;
        }

        return GetClosestBiomeIndex(currentHeight, currentTemperature, currentMoisture);
    }

    int GetClosestBiomeIndex(float currentHeight, float currentTemperature, float currentMoisture)
    {
        int closestBiomeIndex = 0;
        float bestScore = float.MaxValue;

        for (int i = 0; i < biomes.Length; i++)
        {
            BiomeType biome = biomes[i];

            float heightDistance = GetRangeDistance(currentHeight, biome.minHeight, biome.maxHeight);
            float temperatureDistance = GetRangeDistance(currentTemperature, biome.minTemperature, biome.maxTemperature);
            float moistureDistance = GetRangeDistance(currentMoisture, biome.minMoisture, biome.maxMoisture);

            float score = heightDistance + temperatureDistance + moistureDistance;

            if (score < bestScore)
            {
                bestScore = score;
                closestBiomeIndex = i;
            }
        }

        return closestBiomeIndex;
    }

    Color[] SmoothColorMap(Color[] originalColorMap, int[] biomeIndexMap, int radius, float strength)
    {
        Color[] smoothedColorMap = new Color[originalColorMap.Length];

        for (int y = 0; y < mapChunkSize; y++)
        {
            for (int x = 0; x < mapChunkSize; x++)
            {
                int index = y * mapChunkSize + x;
                int currentBiomeIndex = biomeIndexMap[index];

                if (currentBiomeIndex < 0)
                {
                    smoothedColorMap[index] = originalColorMap[index];
                    continue;
                }

                BiomeType currentBiome = biomes[currentBiomeIndex];

                if (!currentBiome.allowColorBlend)
                {
                    smoothedColorMap[index] = originalColorMap[index];
                    continue;
                }

                Color averageColor = Color.black;
                float totalWeight = 0f;
                bool foundBlendableNeighbor = false;

                for (int offsetY = -radius; offsetY <= radius; offsetY++)
                {
                    for (int offsetX = -radius; offsetX <= radius; offsetX++)
                    {
                        int sampleX = Mathf.Clamp(x + offsetX, 0, mapChunkSize - 1);
                        int sampleY = Mathf.Clamp(y + offsetY, 0, mapChunkSize - 1);
                        int sampleIndex = sampleY * mapChunkSize + sampleX;
                        int neighborBiomeIndex = biomeIndexMap[sampleIndex];

                        if (neighborBiomeIndex < 0)
                        {
                            continue;
                        }

                        BiomeType neighborBiome = biomes[neighborBiomeIndex];

                        if (!neighborBiome.allowColorBlend)
                        {
                            continue;
                        }

                        if (neighborBiomeIndex != currentBiomeIndex)
                        {
                            foundBlendableNeighbor = true;
                        }

                        float distance = Mathf.Sqrt(offsetX * offsetX + offsetY * offsetY);
                        float weight = 1f / (1f + distance);

                        averageColor += originalColorMap[sampleIndex] * weight;
                        totalWeight += weight;
                    }
                }

                if (!foundBlendableNeighbor || totalWeight <= 0f)
                {
                    smoothedColorMap[index] = originalColorMap[index];
                    continue;
                }

                averageColor /= totalWeight;
                smoothedColorMap[index] = Color.Lerp(originalColorMap[index], averageColor, strength);
            }
        }

        return smoothedColorMap;
    }

    Color GetBaseBiomeColor(float currentHeight, float currentTemperature, float currentMoisture)
    {
        return GetBiome(currentHeight, currentTemperature, currentMoisture).color;
    }

    public Color GetColor(float currentHeight, float currentTemperature, float currentMoisture)
    {
        return GetBaseBiomeColor(currentHeight, currentTemperature, currentMoisture);
    }

    public Color GetColor(float currentHeight, float currentTemperature)
    {
        return GetBaseBiomeColor(currentHeight, currentTemperature, 0.5f);
    }

    public BiomeType GetBiome(float currentHeight, float currentTemperature, float currentMoisture)
    {
        int biomeIndex = GetBiomeIndex(currentHeight, currentTemperature, currentMoisture);
        return biomes[biomeIndex];
    }

    BiomeType GetClosestBiome(float currentHeight, float currentTemperature, float currentMoisture)
    {
        BiomeType closestBiome = biomes[0];
        float bestScore = float.MaxValue;

        for (int i = 0; i < biomes.Length; i++)
        {
            BiomeType biome = biomes[i];

            float heightDistance = GetRangeDistance(currentHeight, biome.minHeight, biome.maxHeight);
            float temperatureDistance = GetRangeDistance(currentTemperature, biome.minTemperature, biome.maxTemperature);
            float moistureDistance = GetRangeDistance(currentMoisture, biome.minMoisture, biome.maxMoisture);

            float score = heightDistance + temperatureDistance + moistureDistance;

            if (score < bestScore)
            {
                bestScore = score;
                closestBiome = biome;
            }
        }

        return closestBiome;
    }

    float GetRangeDistance(float value, float min, float max)
    {
        if (value < min)
        {
            return min - value;
        }

        if (value > max)
        {
            return value - max;
        }

        return 0f;
    }

    DecorationSpawnData[] GenerateDecorationData(MapData mapData, Vector2 chunkPosition)
    {
        List<DecorationSpawnData> spawnData = new List<DecorationSpawnData>();

        int size = mapChunkSize;
        float topLeftX = (size - 1) / -2f;
        float topLeftZ = (size - 1) / 2f;

        int maxLayerCount = GetMaxLayerCount(mapData);
        LayerSpawnCache spawnCache = new LayerSpawnCache();

        for (int layerIndex = 0; layerIndex < maxLayerCount; layerIndex++)
        {
            for (int y = 0; y < size; y++)
            {
                for (int x = 0; x < size; x++)
                {
                    float currentHeight = mapData.heightMap[x, y];
                    float currentTemperature = mapData.temperatureMap[x, y];
                    float currentMoisture = mapData.moistureMap[x, y];

                    BiomeType biome = GetBiome(currentHeight, currentTemperature, currentMoisture);

                    if (biome.decorationLayers == null || layerIndex >= biome.decorationLayers.Length)
                    {
                        continue;
                    }

                    DecorationLayer layer = biome.decorationLayers[layerIndex];

                    if (layer.prefabs == null || layer.prefabs.Length == 0)
                    {
                        continue;
                    }

                    int sampleInterval = Mathf.Max(1, layer.sampleInterval);

                    if (x % sampleInterval != 0 || y % sampleInterval != 0)
                    {
                        continue;
                    }

                    int attempts = Mathf.Max(1, layer.attemptsPerTile);
                    int randomSeed = GetDecorationSeed(chunkPosition, x, y, layerIndex, seed);
                    System.Random random = new System.Random(randomSeed);

                    for (int attempt = 0; attempt < attempts; attempt++)
                    {
                        float offsetX = RandomRange(random, -layer.randomOffsetRange.x, layer.randomOffsetRange.x);
                        float offsetZ = RandomRange(random, -layer.randomOffsetRange.y, layer.randomOffsetRange.y);

                        float localX = topLeftX + x + offsetX;
                        float localZ = topLeftZ - y + offsetZ;

                        float worldX = chunkPosition.x + localX;
                        float worldZ = chunkPosition.y + localZ;

                        float noiseValue = GetNoiseValue(layer, worldX, worldZ);

                        if (noiseValue < layer.noiseThreshold)
                        {
                            continue;
                        }

                        if (RandomRange(random, 0f, 1f) > layer.spawnChance)
                        {
                            continue;
                        }

                        string layerKey = GetLayerKey(biome, layer, layerIndex);

                        if (!spawnCache.CanSpawn(layerKey, new Vector2(worldX, worldZ), layer.minDistance))
                        {
                            continue;
                        }

                        int prefabIndex = random.Next(0, layer.prefabs.Length);
                        float rotationY = RandomRange(random, 0f, 360f);

                        float minScale = Mathf.Min(layer.randomScaleRange.x, layer.randomScaleRange.y);
                        float maxScale = Mathf.Max(layer.randomScaleRange.x, layer.randomScaleRange.y);
                        float uniformScale = RandomRange(random, minScale, maxScale);

                        spawnData.Add(new DecorationSpawnData(
                            x,
                            y,
                            layerIndex,
                            prefabIndex,
                            localX,
                            localZ,
                            currentHeight,
                            rotationY,
                            uniformScale
                        ));

                        spawnCache.Register(layerKey, new Vector2(worldX, worldZ));
                    }
                }
            }
        }

        return spawnData.ToArray();
    }

    int GetMaxLayerCount(MapData mapData)
    {
        int maxLayerCount = 0;

        for (int y = 0; y < mapChunkSize; y++)
        {
            for (int x = 0; x < mapChunkSize; x++)
            {
                BiomeType biome = GetBiome(mapData.heightMap[x, y], mapData.temperatureMap[x, y], mapData.moistureMap[x, y]);

                if (biome.decorationLayers != null && biome.decorationLayers.Length > maxLayerCount)
                {
                    maxLayerCount = biome.decorationLayers.Length;
                }
            }
        }

        return maxLayerCount;
    }

    float GetNoiseValue(DecorationLayer layer, float worldX, float worldZ)
    {
        float scale = layer.noiseScale <= 0.0001f ? 0.0001f : layer.noiseScale;

        return Mathf.PerlinNoise(
            (worldX + layer.noiseOffset.x) / scale,
            (worldZ + layer.noiseOffset.y) / scale
        );
    }

    string GetLayerKey(BiomeType biome, DecorationLayer layer, int layerIndex)
    {
        string biomeName = string.IsNullOrWhiteSpace(biome.name) ? "Biome" : biome.name;
        string layerName = string.IsNullOrWhiteSpace(layer.name) ? "Layer" + layerIndex : layer.name;
        return biomeName + "_" + layerName;
    }

    int GetDecorationSeed(Vector2 chunkPosition, int x, int y, int layerIndex, int baseSeed)
    {
        unchecked
        {
            int hash = 17;
            hash = hash * 31 + baseSeed;
            hash = hash * 31 + Mathf.RoundToInt(chunkPosition.x);
            hash = hash * 31 + Mathf.RoundToInt(chunkPosition.y);
            hash = hash * 31 + x;
            hash = hash * 31 + y;
            hash = hash * 31 + layerIndex;
            return hash;
        }
    }

    float RandomRange(System.Random random, float min, float max)
    {
        return (float)(min + (max - min) * random.NextDouble());
    }

    void OnValidate()
    {
        if (lacunarity < 1)
        {
            lacunarity = 1;
        }

        if (octaves < 0)
        {
            octaves = 0;
        }

        biomeColorSmoothRadius = Mathf.Max(0, biomeColorSmoothRadius);
        biomeColorSmoothStrength = Mathf.Clamp01(biomeColorSmoothStrength);
        biomeBlendSoftness = Mathf.Clamp(biomeBlendSoftness, 0f, 0.5f);
        biomeBoundaryNoiseScale = Mathf.Max(0.0001f, biomeBoundaryNoiseScale);
        biomeBoundaryNoiseHeightInfluence = Mathf.Clamp(biomeBoundaryNoiseHeightInfluence, 0f, 0.25f);
        biomePatchNoiseScale = Mathf.Max(0.0001f, biomePatchNoiseScale);
        biomePatchNoiseStrength = Mathf.Clamp01(biomePatchNoiseStrength);
        snowLineNoiseScale = Mathf.Max(0.0001f, snowLineNoiseScale);
        snowLineNoiseHeightInfluence = Mathf.Clamp(snowLineNoiseHeightInfluence, 0f, 0.25f);
        snowHoleNoiseScale = Mathf.Max(0.0001f, snowHoleNoiseScale);
        snowHoleStrength = Mathf.Clamp01(snowHoleStrength);
        snowHoleThreshold = Mathf.Clamp01(snowHoleThreshold);
    }

    struct MapThreadInfo<T>
    {
        public readonly Action<T> callback;
        public readonly T parameter;

        public MapThreadInfo(Action<T> callback, T parameter)
        {
            this.callback = callback;
            this.parameter = parameter;
        }
    }

    class LayerSpawnCache
    {
        Dictionary<string, List<Vector2>> positionsByLayer = new Dictionary<string, List<Vector2>>();

        public bool CanSpawn(string key, Vector2 worldPosition, float minDistance)
        {
            if (minDistance <= 0f)
            {
                return true;
            }

            if (!positionsByLayer.TryGetValue(key, out List<Vector2> positions))
            {
                return true;
            }

            float minDistanceSqr = minDistance * minDistance;

            for (int i = 0; i < positions.Count; i++)
            {
                Vector2 delta = positions[i] - worldPosition;

                if (delta.sqrMagnitude < minDistanceSqr)
                {
                    return false;
                }
            }

            return true;
        }

        public void Register(string key, Vector2 worldPosition)
        {
            if (!positionsByLayer.TryGetValue(key, out List<Vector2> positions))
            {
                positions = new List<Vector2>();
                positionsByLayer[key] = positions;
            }

            positions.Add(worldPosition);
        }
    }
}


[System.Serializable]
public struct DecorationLayer
{
    public string name;
    public GameObject[] prefabs;

    [Range(0f, 1f)]
    public float spawnChance;

    public float noiseScale;

    [Range(0f, 1f)]
    public float noiseThreshold;

    public float minDistance;
    public int attemptsPerTile;
    public int sampleInterval;
    public Vector2 randomOffsetRange;
    public Vector2 randomScaleRange;
    public Vector2 noiseOffset;
}

public enum BiomeTextureType
{
    Auto,
    Water,
    Beach,
    Plains,
    Forest,
    Desert,
    Mountain,
    Snow
}

[System.Serializable]
public struct BiomeType
{
    public string name;
    public BiomeTextureType textureType;

    public bool allowColorBlend;

    [Range(0f, 1f)]
    public float minHeight;

    [Range(0f, 1f)]
    public float maxHeight;

    [Range(0f, 1f)]
    public float minTemperature;

    [Range(0f, 1f)]
    public float maxTemperature;

    [Range(0f, 1f)]
    public float minMoisture;

    [Range(0f, 1f)]
    public float maxMoisture;

    public int priority;
    public Color color;
    public DecorationLayer[] decorationLayers;
}

public struct DecorationSpawnData
{
    public readonly int tileX;
    public readonly int tileY;
    public readonly int layerIndex;
    public readonly int prefabIndex;
    public readonly float localX;
    public readonly float localZ;
    public readonly float heightValue;
    public readonly float rotationY;
    public readonly float uniformScale;

    public DecorationSpawnData(
        int tileX,
        int tileY,
        int layerIndex,
        int prefabIndex,
        float localX,
        float localZ,
        float heightValue,
        float rotationY,
        float uniformScale
    )
    {
        this.tileX = tileX;
        this.tileY = tileY;
        this.layerIndex = layerIndex;
        this.prefabIndex = prefabIndex;
        this.localX = localX;
        this.localZ = localZ;
        this.heightValue = heightValue;
        this.rotationY = rotationY;
        this.uniformScale = uniformScale;
    }
}

public struct MapData
{
    public readonly float[,] heightMap;
    public readonly float[,] temperatureMap;
    public readonly float[,] moistureMap;
    public readonly Color[] colorMap;
    public readonly Color[] biomeControlMapA;
    public readonly Color[] biomeControlMapB;

    public MapData(float[,] heightMap, float[,] temperatureMap, float[,] moistureMap, Color[] colorMap, Color[] biomeControlMapA, Color[] biomeControlMapB)
    {
        this.heightMap = heightMap;
        this.temperatureMap = temperatureMap;
        this.moistureMap = moistureMap;
        this.colorMap = colorMap;
        this.biomeControlMapA = biomeControlMapA;
        this.biomeControlMapB = biomeControlMapB;
    }
}