using UnityEngine;

public class TextureMapVisualizer : MonoBehaviour
{
    public enum MapDisplayMode
    {
        LandOcean,
        Temperature
    }

    [SerializeField] private Renderer targetRenderer;
    [SerializeField] private int pixelsPerCell = 16;

    private Texture2D currentTexture;

    public void Draw(MapDataOLD map, MapDisplayMode displayMode)
    {
        int textureWidth = map.Width * pixelsPerCell;
        int textureHeight = map.Height * pixelsPerCell;

        currentTexture = new Texture2D(textureWidth, textureHeight, TextureFormat.RGBA32, false);
        currentTexture.filterMode = FilterMode.Point;
        currentTexture.wrapMode = TextureWrapMode.Clamp;

        for (int y = 0; y < map.Height; y++)
        {
            for (int x = 0; x < map.Width; x++)
            {
                Color color = GetColor(map, x, y, displayMode);
                FillCell(x, y, color, currentTexture);
            }
        }

        currentTexture.Apply();
        targetRenderer.material.mainTexture = currentTexture;

        transform.localScale = new Vector3(map.Width, 1f, map.Height);
    }

    private void FillCell(int cellX, int cellY, Color color, Texture2D texture)
    {
        int startX = cellX * pixelsPerCell;
        int startY = cellY * pixelsPerCell;

        for (int y = 0; y < pixelsPerCell; y++)
        {
            for (int x = 0; x < pixelsPerCell; x++)
            {
                texture.SetPixel(startX + x, startY + y, color);
            }
        }
    }

    private Color GetColor(MapDataOLD map, int x, int y, MapDisplayMode displayMode)
    {
        if (displayMode == MapDisplayMode.LandOcean)
        {
            return map.GetCell(x, y) switch
            {
                BiomeMapGenerator.Ocean => Color.blue,
                BiomeMapGenerator.Land => Color.green,
                _ => Color.magenta
            };
        }

        return map.GetTemperature(x, y) switch
        {
            BiomeMapGenerator.Cold => Color.cyan,
            BiomeMapGenerator.Moderate => Color.yellow,
            BiomeMapGenerator.Warm => Color.red,
            _ => Color.magenta
        };
    }
}