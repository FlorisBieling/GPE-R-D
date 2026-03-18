using Unity.VisualScripting;
using UnityEngine;

public class MapGenerator : MonoBehaviour
{
    public enum DrawMode { NoiseMap, ColorMap };
    public DrawMode drawMode;

    public int mapWidth;
    public int mapHeight;
    public float noiseScale;

    public int octaves;
    [Range(0, 1)]
    public float persistance;
    public float lacunarity;

    public int seed;
    [Range(0, 10)]
    public float redistributionPower;
    public Vector2 offset;

    public bool autoUpdate;

    public HeightTypes[] heightTypes;

    public void GenerateMap()
    {
        float[,] heightMap = Noise.GenerateNoiseMap(mapWidth, mapHeight, seed, noiseScale, octaves, persistance, lacunarity, offset);
        float[,] temperatureMap = Noise.GenerateNoiseMap(mapWidth, mapHeight, seed + 1, noiseScale, octaves, persistance, lacunarity, offset);

        MapDisplay display = FindObjectOfType<MapDisplay>();
        if (drawMode == DrawMode.NoiseMap)
        {
            display.DrawTexture(TextureGenerator.TextureFromHeightMap(heightMap));
        }
        else if (drawMode == DrawMode.ColorMap)
        {
            display.DrawTexture(TextureGenerator.TextureFromColorMap(CombineMaps(heightMap, temperatureMap), mapWidth, mapHeight));
        }
    }

    private void OnValidate()
    {
        if (mapWidth < 1)
        {
            mapWidth = 1;
        }
        if (mapHeight < 1)
        {
            mapHeight = 1;
        }
        if (lacunarity < 1)
        {
            lacunarity = 1;
        }
        if (octaves < 0)
        {
            octaves = 0;
        }
    }

    // CombineMaps takes the height and temperature maps and combines them to create a color map.
    public Color[] CombineMaps(float[,] heightMap, float[,] temperatureMap)
    {
        Color[] colorMap = new Color[mapWidth * mapHeight];
        for (int y = 0; y < mapHeight; y++)
        {
            for (int x = 0; x < mapWidth; x++)
            {
                float currentHeight = Mathf.Pow(heightMap[x, y], redistributionPower);
                float currentTemperature = temperatureMap[x, y];

                colorMap[y * mapWidth + x] = GetColor(currentHeight, currentTemperature);
            }
        }
        return colorMap;
    }

    // GetColor uses the height and temperature to determine the color of the pixel.
    public Color GetColor(float currentHeight, float currentTemperature)
    {
        for (int i = 0; i < heightTypes.Length; i++)
        {
            if (currentHeight <= heightTypes[i].height)
            {
                for (int j = 0; j < heightTypes[i].biomeTypes.Length; j++)
                {
                    if (currentTemperature <= heightTypes[i].biomeTypes[j].temperature)
                    {
                        return heightTypes[i].biomeTypes[j].color;
                    }
                }
            }
        }
        return Color.red;
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
}