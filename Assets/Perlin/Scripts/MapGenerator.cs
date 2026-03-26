using System;
using System.Collections.Generic;
using System.Threading;
using Unity.VisualScripting;
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

    void MapDataThread(Vector2 centre, Action<MapData> callback) {
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

    void MeshDataThread(MapData mapData, int lod, Action<MeshData> callback) {
        MeshData meshData = MeshGenerator.GenerateTerrainMesh(mapData.heightMap, meshHeightMultiplier, meshHeightCurve, lod);
        lock (meshDataThreadInfoQueue)
        {
            meshDataThreadInfoQueue.Enqueue(new MapThreadInfo<MeshData>(callback, meshData));
        }
    }

    void Update()
    {
        if (mapDataThreadInfoQueue.Count > 0)
        {
            for (int i = 0; i < mapDataThreadInfoQueue.Count; i++)
            {
                MapThreadInfo<MapData> threadInfo = mapDataThreadInfoQueue.Dequeue();
                threadInfo.callback(threadInfo.parameter);
            }
        }

        if (meshDataThreadInfoQueue.Count > 0)
        {
            for (int i = 0; i < meshDataThreadInfoQueue.Count; i++)
            {
                MapThreadInfo<MeshData> threadInfo = meshDataThreadInfoQueue.Dequeue();
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
        float[,] heightMap = Noise.GenerateNoiseMap(mapChunkSize, mapChunkSize, seed, noiseScale, octaves, persistance, lacunarity, centre + offset, normalizeMode);
        float[,] temperatureMap = Noise.GenerateNoiseMap(mapChunkSize, mapChunkSize, seed + 1, noiseScale*5f, octaves, persistance, lacunarity, centre + offset, normalizeMode);
        
        return new MapData(heightMap, temperatureMap, CombineMaps(heightMap, temperatureMap));
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

    // CombineMaps takes the height and temperature maps and combines them to create a color map.
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

    // GetColor uses the height and temperature to determine the color of the pixel.
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
}

// HeightTypes are determined by height and use the temperature to determine the biome type.
[System.Serializable]
public struct HeightTypes
{
    public string name;
    public float height;
    public BiomeType[] biomeTypes;
}

[System.Serializable]
public struct BiomeType
{
    public string name;
    public float temperature;
    public Color color;
    public GameObject[] decorationPrefabs;
    [Range(0f, 1f)]
    public float decorationChance;
}

public struct MapData {
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