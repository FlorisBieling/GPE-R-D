using System;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;

public class MapGenerator : MonoBehaviour
{
    public enum DrawMode
    {
        HeightNoiseMap,
        TemperatureNoiseMap,
        MoistureNoiseMap,
        ColorMap,
        BiomeControlMapA,
        BiomeControlMapB,
        Mesh
    }

    public DrawMode drawMode;
    public Noise.NormalizeMode normalizeMode;
    public const int mapChunkSize = 241;

    [Range(0, 6)] public int editorPreviewLOD;
    public float noiseScale;
    public int octaves;
    [Range(0, 1)] public float persistance;
    public float lacunarity;
    public int seed;
    [Range(0, 10)] public float redistributionPower;
    public Vector2 offset;
    public float meshHeightMultiplier;
    public AnimationCurve meshHeightCurve;
    public bool autoUpdate;

    [Header("Biome Color Smoothing")]
    [Range(0, 3)] public int biomeColorSmoothRadius = 1;
    [Range(0f, 1f)] public float biomeColorSmoothStrength = 0.25f;

    [Header("Climate Maps")]
    public float temperatureNoiseScaleMultiplier = 5f;
    public Vector2 temperatureOffset;
    public float moistureNoiseScaleMultiplier = 6f;
    public Vector2 moistureOffset;

    [Header("Biome Texture Blending")]
    [Range(0f, 0.5f)] public float biomeBlendSoftness = 0.08f;
    public float biomeBoundaryNoiseScale = 65f;
    [Range(0f, 0.25f)] public float biomeBoundaryNoiseHeightInfluence = 0.045f;
    public float biomePatchNoiseScale = 45f;
    [Range(0f, 1f)] public float biomePatchNoiseStrength = 0.25f;
    public Vector2 biomeBlendNoiseOffset;

    [Header("Snow Texture Blend")]
    public bool useSnowMask = true;
    [Range(0f, 1f)] public float snowStartHeight = 0.75f;
    [Range(0f, 1f)] public float snowEndHeight = 0.85f;
    public float snowLineNoiseScale = 70f;
    [Range(0f, 0.25f)] public float snowLineNoiseHeightInfluence = 0.08f;
    public float snowHoleNoiseScale = 25f;
    [Range(0f, 1f)] public float snowHoleStrength = 0.25f;
    [Range(0f, 1f)] public float snowHoleThreshold = 0.45f;
    public Vector2 snowNoiseOffset;

    [Header("Biomes")]
    public BiomeType[] biomes;

    readonly Queue<MapThreadInfo<MapData>> mapDataQueue = new Queue<MapThreadInfo<MapData>>();
    readonly Queue<MapThreadInfo<MeshData>> meshDataQueue = new Queue<MapThreadInfo<MeshData>>();
    readonly Queue<MapThreadInfo<DecorationSpawnData[]>> decorationDataQueue = new Queue<MapThreadInfo<DecorationSpawnData[]>>();

    public void DrawMapInEditor()
    {
        MapData mapData = GenerateMapData(Vector2.zero);
        MapDisplay display = FindObjectOfType<MapDisplay>();
        if (display == null) return;

        switch (drawMode)
        {
            case DrawMode.HeightNoiseMap:
                display.DrawMesh(
                    MeshGenerator.GenerateTerrainMesh(mapData.heightMap, meshHeightMultiplier, meshHeightCurve, editorPreviewLOD),
                    TextureGenerator.TextureFromHeightMap(mapData.heightMap)
                );
                break;

            case DrawMode.TemperatureNoiseMap:
                display.DrawMesh(
                    MeshGenerator.GenerateTerrainMesh(mapData.temperatureMap, meshHeightMultiplier, meshHeightCurve, editorPreviewLOD, true),
                    TextureGenerator.TextureFromHeightMap(mapData.temperatureMap)
                );
                break;

            case DrawMode.MoistureNoiseMap:
                display.DrawMesh(
                    MeshGenerator.GenerateTerrainMesh(mapData.moistureMap, meshHeightMultiplier, meshHeightCurve, editorPreviewLOD, true),
                    TextureGenerator.TextureFromHeightMap(mapData.moistureMap)
                );
                break;

            case DrawMode.ColorMap:
                display.DrawTexture(TextureGenerator.TextureFromColorMap(mapData.colorMap, mapChunkSize, mapChunkSize));
                break;

            case DrawMode.BiomeControlMapA:
                display.DrawTexture(TextureGenerator.TextureFromColorMap(mapData.biomeControlMapA, mapChunkSize, mapChunkSize));
                break;

            case DrawMode.BiomeControlMapB:
                display.DrawTexture(TextureGenerator.TextureFromColorMap(mapData.biomeControlMapB, mapChunkSize, mapChunkSize));
                break;

            case DrawMode.Mesh:
                display.DrawMesh(
                    MeshGenerator.GenerateTerrainMesh(mapData.heightMap, meshHeightMultiplier, meshHeightCurve, editorPreviewLOD),
                    TextureGenerator.TextureFromColorMap(mapData.colorMap, mapChunkSize, mapChunkSize),
                    TextureGenerator.TextureFromColorMap(mapData.biomeControlMapA, mapChunkSize, mapChunkSize),
                    TextureGenerator.TextureFromColorMap(mapData.biomeControlMapB, mapChunkSize, mapChunkSize)
                );
                break;
        }
    }

    public void RequestMapData(Vector2 centre, Action<MapData> callback)
    {
        new Thread(() =>
        {
            MapData data = GenerateMapData(centre);
            lock (mapDataQueue)
            {
                mapDataQueue.Enqueue(new MapThreadInfo<MapData>(callback, data));
            }
        }).Start();
    }

    public void RequestMeshData(MapData mapData, int lod, Action<MeshData> callback)
    {
        new Thread(() =>
        {
            MeshData data = MeshGenerator.GenerateTerrainMesh(mapData.heightMap, meshHeightMultiplier, meshHeightCurve, lod);
            lock (meshDataQueue)
            {
                meshDataQueue.Enqueue(new MapThreadInfo<MeshData>(callback, data));
            }
        }).Start();
    }

    public void RequestDecorationData(MapData mapData, Vector2 chunkPosition, Action<DecorationSpawnData[]> callback)
    {
        new Thread(() =>
        {
            DecorationSpawnData[] data = CreateDecorationGenerator().Generate(mapData, chunkPosition);
            lock (decorationDataQueue)
            {
                decorationDataQueue.Enqueue(new MapThreadInfo<DecorationSpawnData[]>(callback, data));
            }
        }).Start();
    }

    public float GetMeshHeight(float heightValue)
    {
        return meshHeightCurve.Evaluate(heightValue) * meshHeightMultiplier;
    }

    public int GetBiomeIndex(float height, float temperature, float moisture)
    {
        return CreateBiomeGenerator().GetBiomeIndex(height, temperature, moisture);
    }

    public BiomeType GetBiome(float height, float temperature, float moisture)
    {
        return CreateBiomeGenerator().GetBiome(height, temperature, moisture);
    }

    public Color[] CombineMaps(float[,] heightMap, float[,] temperatureMap, float[,] moistureMap)
    {
        return CreateBiomeGenerator().GenerateColorMap(heightMap, temperatureMap, moistureMap);
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

        BiomeGenerator biomeGenerator = CreateBiomeGenerator();
        Color[] colorMap = biomeGenerator.GenerateColorMap(heightMap, temperatureMap, moistureMap);
        BiomeControlMapGenerator controlMapGenerator = new BiomeControlMapGenerator(this, biomeGenerator);
        controlMapGenerator.Generate(heightMap, temperatureMap, moistureMap, centre, out Color[] controlMapA, out Color[] controlMapB);

        return new MapData(heightMap, temperatureMap, moistureMap, colorMap, controlMapA, controlMapB);
    }

    BiomeGenerator CreateBiomeGenerator()
    {
        return new BiomeGenerator(biomes, mapChunkSize, biomeColorSmoothRadius, biomeColorSmoothStrength);
    }

    DecorationGenerator CreateDecorationGenerator()
    {
        return new DecorationGenerator(mapChunkSize, seed, CreateBiomeGenerator());
    }

    void Update()
    {
        FlushQueue(mapDataQueue);
        FlushQueue(meshDataQueue);
        FlushQueue(decorationDataQueue);
    }

    static void FlushQueue<T>(Queue<MapThreadInfo<T>> queue)
    {
        lock (queue)
        {
            while (queue.Count > 0)
            {
                MapThreadInfo<T> threadInfo = queue.Dequeue();
                threadInfo.callback?.Invoke(threadInfo.parameter);
            }
        }
    }

    void OnValidate()
    {
        lacunarity = Mathf.Max(1f, lacunarity);
        octaves = Mathf.Max(0, octaves);
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

    readonly struct MapThreadInfo<T>
    {
        public readonly Action<T> callback;
        public readonly T parameter;

        public MapThreadInfo(Action<T> callback, T parameter)
        {
            this.callback = callback;
            this.parameter = parameter;
        }
    }
}
