using UnityEngine;

[System.Serializable]
public struct DecorationLayer
{
    public string name;
    public GameObject[] prefabs;

    [Range(0f, 1f)] public float spawnChance;
    public float noiseScale;
    [Range(0f, 1f)] public float noiseThreshold;
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

    [Range(0f, 1f)] public float minHeight;
    [Range(0f, 1f)] public float maxHeight;
    [Range(0f, 1f)] public float minTemperature;
    [Range(0f, 1f)] public float maxTemperature;
    [Range(0f, 1f)] public float minMoisture;
    [Range(0f, 1f)] public float maxMoisture;

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

    public DecorationSpawnData(int tileX, int tileY, int layerIndex, int prefabIndex, float localX, float localZ, float heightValue, float rotationY, float uniformScale)
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
