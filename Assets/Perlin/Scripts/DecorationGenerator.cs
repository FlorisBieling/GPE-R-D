using System.Collections.Generic;
using UnityEngine;

public sealed class DecorationGenerator
{
    readonly int mapSize;
    readonly int seed;
    readonly BiomeGenerator biomeGenerator;

    public DecorationGenerator(int mapSize, int seed, BiomeGenerator biomeGenerator)
    {
        this.mapSize = mapSize;
        this.seed = seed;
        this.biomeGenerator = biomeGenerator;
    }

    public DecorationSpawnData[] Generate(MapData mapData, Vector2 chunkPosition)
    {
        List<DecorationSpawnData> spawnData = new List<DecorationSpawnData>();
        float topLeftX = (mapSize - 1) / -2f;
        float topLeftZ = (mapSize - 1) / 2f;
        int maxLayerCount = GetMaxLayerCount(mapData);
        LayerSpawnCache spawnCache = new LayerSpawnCache();

        for (int layerIndex = 0; layerIndex < maxLayerCount; layerIndex++)
        {
            for (int y = 0; y < mapSize; y++)
            {
                for (int x = 0; x < mapSize; x++)
                {
                    float height = mapData.heightMap[x, y];
                    BiomeType biome = biomeGenerator.GetBiome(height, mapData.temperatureMap[x, y], mapData.moistureMap[x, y]);
                    if (biome.decorationLayers == null || layerIndex >= biome.decorationLayers.Length) continue;

                    DecorationLayer layer = biome.decorationLayers[layerIndex];
                    if (layer.prefabs == null || layer.prefabs.Length == 0) continue;

                    int sampleInterval = Mathf.Max(1, layer.sampleInterval);
                    if (x % sampleInterval != 0 || y % sampleInterval != 0) continue;

                    System.Random random = new System.Random(GetDecorationSeed(chunkPosition, x, y, layerIndex));
                    int attempts = Mathf.Max(1, layer.attemptsPerTile);

                    for (int attempt = 0; attempt < attempts; attempt++)
                    {
                        float localX = topLeftX + x + RandomRange(random, -layer.randomOffsetRange.x, layer.randomOffsetRange.x);
                        float localZ = topLeftZ - y + RandomRange(random, -layer.randomOffsetRange.y, layer.randomOffsetRange.y);
                        float worldX = chunkPosition.x + localX;
                        float worldZ = chunkPosition.y + localZ;

                        if (GetNoiseValue(layer, worldX, worldZ) < layer.noiseThreshold) continue;
                        if (RandomRange(random, 0f, 1f) > layer.spawnChance) continue;

                        string layerKey = GetLayerKey(biome, layer, layerIndex);
                        Vector2 worldPosition = new Vector2(worldX, worldZ);
                        if (!spawnCache.CanSpawn(layerKey, worldPosition, layer.minDistance)) continue;

                        float minScale = Mathf.Min(layer.randomScaleRange.x, layer.randomScaleRange.y);
                        float maxScale = Mathf.Max(layer.randomScaleRange.x, layer.randomScaleRange.y);
                        spawnData.Add(new DecorationSpawnData(
                            x,
                            y,
                            layerIndex,
                            random.Next(0, layer.prefabs.Length),
                            localX,
                            localZ,
                            height,
                            RandomRange(random, 0f, 360f),
                            RandomRange(random, minScale, maxScale)
                        ));
                        spawnCache.Register(layerKey, worldPosition);
                    }
                }
            }
        }

        return spawnData.ToArray();
    }

    int GetMaxLayerCount(MapData mapData)
    {
        int max = 0;
        for (int y = 0; y < mapSize; y++)
        {
            for (int x = 0; x < mapSize; x++)
            {
                BiomeType biome = biomeGenerator.GetBiome(mapData.heightMap[x, y], mapData.temperatureMap[x, y], mapData.moistureMap[x, y]);
                if (biome.decorationLayers != null) max = Mathf.Max(max, biome.decorationLayers.Length);
            }
        }
        return max;
    }

    static float GetNoiseValue(DecorationLayer layer, float worldX, float worldZ)
    {
        float scale = Mathf.Max(0.0001f, layer.noiseScale);
        return Mathf.PerlinNoise((worldX + layer.noiseOffset.x) / scale, (worldZ + layer.noiseOffset.y) / scale);
    }

    static string GetLayerKey(BiomeType biome, DecorationLayer layer, int layerIndex)
    {
        string biomeName = string.IsNullOrWhiteSpace(biome.name) ? "Biome" : biome.name;
        string layerName = string.IsNullOrWhiteSpace(layer.name) ? "Layer" + layerIndex : layer.name;
        return biomeName + "_" + layerName;
    }

    int GetDecorationSeed(Vector2 chunkPosition, int x, int y, int layerIndex)
    {
        unchecked
        {
            int hash = 17;
            hash = hash * 31 + seed;
            hash = hash * 31 + Mathf.RoundToInt(chunkPosition.x);
            hash = hash * 31 + Mathf.RoundToInt(chunkPosition.y);
            hash = hash * 31 + x;
            hash = hash * 31 + y;
            hash = hash * 31 + layerIndex;
            return hash;
        }
    }

    static float RandomRange(System.Random random, float min, float max)
    {
        return (float)(min + (max - min) * random.NextDouble());
    }

    sealed class LayerSpawnCache
    {
        readonly Dictionary<string, List<Vector2>> positionsByLayer = new Dictionary<string, List<Vector2>>();

        public bool CanSpawn(string key, Vector2 position, float minDistance)
        {
            if (minDistance <= 0f || !positionsByLayer.TryGetValue(key, out List<Vector2> positions)) return true;
            float minDistanceSqr = minDistance * minDistance;
            for (int i = 0; i < positions.Count; i++)
            {
                if ((positions[i] - position).sqrMagnitude < minDistanceSqr) return false;
            }
            return true;
        }

        public void Register(string key, Vector2 position)
        {
            if (!positionsByLayer.TryGetValue(key, out List<Vector2> positions))
            {
                positions = new List<Vector2>();
                positionsByLayer[key] = positions;
            }
            positions.Add(position);
        }
    }
}
