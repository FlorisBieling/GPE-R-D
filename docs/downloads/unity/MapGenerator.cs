using System;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;

public class MapGenerator : MonoBehaviour
{
    public enum DrawMode { HeightNoiseMap, TemperatureNoiseMap, ColorMap, Mesh };
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

    public HeightTypes[] heightTypes;

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
        else if (drawMode == DrawMode.ColorMap)
        {
            display.DrawTexture(TextureGenerator.TextureFromColorMap(mapData.colorMap, mapChunkSize, mapChunkSize));
        }
        else if (drawMode == DrawMode.Mesh)
        {
            display.DrawMesh(
                MeshGenerator.GenerateTerrainMesh(mapData.heightMap, meshHeightMultiplier, meshHeightCurve, editorPreviewLOD),
                TextureGenerator.TextureFromColorMap(mapData.colorMap, mapChunkSize, mapChunkSize)
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
            noiseScale * 5f,
            octaves,
            persistance,
            lacunarity,
            centre + offset,
            normalizeMode
        );

        return new MapData(heightMap, temperatureMap, CombineMaps(heightMap, temperatureMap));
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

                    BiomeType biome = GetBiome(currentHeight, currentTemperature);

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
                BiomeType biome = GetBiome(mapData.heightMap[x, y], mapData.temperatureMap[x, y]);

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

    private void OnValidate()
    {
        if (lacunarity < 1)
        {
            lacunarity = 1;
        }

        if (octaves < 0)
        {
            octaves = 0;
        }
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

    public Color[] CombineMaps(float[,] heightMap, float[,] temperatureMap)
    {
        Color[] colorMap = new Color[mapChunkSize * mapChunkSize];

        for (int y = 0; y < mapChunkSize; y++)
        {
            for (int x = 0; x < mapChunkSize; x++)
            {
                float currentHeight = heightMap[x, y];
                float currentTemperature = temperatureMap[x, y];
                colorMap[y * mapChunkSize + x] = GetColor(currentHeight, currentTemperature);
            }
        }

        return colorMap;
    }

    public Color GetColor(float currentHeight, float currentTemperature)
    {
        return GetBiome(currentHeight, currentTemperature).color;
    }

    public BiomeType GetBiome(float currentHeight, float currentTemperature)
    {
        BiomeType biomeType = new BiomeType();

        for (int i = 0; i < heightTypes.Length; i++)
        {
            if (currentHeight >= heightTypes[i].height)
            {
                for (int j = 0; j < heightTypes[i].biomeTypes.Length; j++)
                {
                    if (currentTemperature >= heightTypes[i].biomeTypes[j].temperature)
                    {
                        biomeType = heightTypes[i].biomeTypes[j];
                    }
                }
            }
        }

        return biomeType;
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
public struct HeightTypes
{
    public string name;
    public float height;
    public BiomeType[] biomeTypes;
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

[System.Serializable]
public struct BiomeType
{
    public string name;
    public float temperature;
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
    public readonly Color[] colorMap;

    public MapData(float[,] heightMap, float[,] temperatureMap, Color[] colorMap)
    {
        this.heightMap = heightMap;
        this.temperatureMap = temperatureMap;
        this.colorMap = colorMap;
    }
}