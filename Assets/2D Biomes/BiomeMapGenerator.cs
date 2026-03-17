using UnityEngine;

public class BiomeMapGenerator : MonoBehaviour
{
    public const int Ocean = 0;
    public const int Land = 1;

    public const int Cold = 0;
    public const int Moderate = 1;
    public const int Warm = 2;

    [SerializeField] private int seed = 12345;

    private System.Random random;

    private void Awake()
    {
        random = new System.Random(seed);
    }

    public MapData GenerateInitialMap(int width, int height, float landChance)
    {
        MapData map = new MapData(width, height);

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                int value = random.NextDouble() < landChance ? Land : Ocean;
                map.SetCell(x, y, value);
            }
        }

        return map;
    }

    public MapData Subdivide(MapData source)
    {
        int newWidth = source.Width * 2;
        int newHeight = source.Height * 2;
        MapData result = new MapData(newWidth, newHeight);

        for (int y = 0; y < source.Height; y++)
        {
            for (int x = 0; x < source.Width; x++)
            {
                int value = source.GetCell(x, y);
                int temperature = source.GetTemperature(x, y);

                int newX = x * 2;
                int newY = y * 2;

                result.SetCell(newX, newY, value);
                result.SetCell(newX + 1, newY, value);
                result.SetCell(newX, newY + 1, value);
                result.SetCell(newX + 1, newY + 1, value);

                result.SetTemperature(newX, newY, temperature);
                result.SetTemperature(newX + 1, newY, temperature);
                result.SetTemperature(newX, newY + 1, temperature);
                result.SetTemperature(newX + 1, newY + 1, temperature);
            }
        }

        return result;
    }

    public MapData MutateCoast(MapData source)
    {
        MapData result = new MapData(source.Width, source.Height);

        for (int y = 0; y < source.Height; y++)
        {
            for (int x = 0; x < source.Width; x++)
            {
                int current = source.GetCell(x, y);
                int temperature = source.GetTemperature(x, y);

                bool touchesLand = HasNeighborOfType(source, x, y, Land);
                bool touchesOcean = HasNeighborOfType(source, x, y, Ocean);

                if (current == Ocean && touchesLand)
                {
                    result.SetCell(x, y, random.NextDouble() < 0.25 ? Land : Ocean);
                }
                else if (current == Land && touchesOcean)
                {
                    result.SetCell(x, y, random.NextDouble() < 0.10 ? Ocean : Land);
                }
                else
                {
                    result.SetCell(x, y, current);
                }

                result.SetTemperature(x, y, temperature);
            }
        }

        return result;
    }

    public MapData AddIslandsInOpenOcean(MapData source)
    {
        MapData result = new MapData(source.Width, source.Height);

        for (int y = 0; y < source.Height; y++)
        {
            for (int x = 0; x < source.Width; x++)
            {
                int current = source.GetCell(x, y);
                int temperature = source.GetTemperature(x, y);

                if (current != Ocean)
                {
                    result.SetCell(x, y, current);
                    result.SetTemperature(x, y, temperature);
                    continue;
                }

                if (IsSurroundedByOcean4Directions(source, x, y))
                {
                    result.SetCell(x, y, random.NextDouble() < 0.50 ? Land : Ocean);
                }
                else
                {
                    result.SetCell(x, y, Ocean);
                }

                result.SetTemperature(x, y, temperature);
            }
        }

        return result;
    }

    public MapData GenerateTemperatures(MapData source)
    {
        MapData result = new MapData(source.Width, source.Height);

        for (int y = 0; y < source.Height; y++)
        {
            for (int x = 0; x < source.Width; x++)
            {
                int cell = source.GetCell(x, y);
                int temperature = random.NextDouble() < 0.5 ? Cold : Warm;

                result.SetCell(x, y, cell);
                result.SetTemperature(x, y, temperature);
            }
        }

        return result;
    }

    private bool HasNeighborOfType(MapData map, int x, int y, int targetType)
    {
        for (int offsetY = -1; offsetY <= 1; offsetY++)
        {
            for (int offsetX = -1; offsetX <= 1; offsetX++)
            {
                if (offsetX == 0 && offsetY == 0)
                {
                    continue;
                }

                int checkX = x + offsetX;
                int checkY = y + offsetY;

                if (checkX < 0 || checkX >= map.Width || checkY < 0 || checkY >= map.Height)
                {
                    continue;
                }

                if (map.GetCell(checkX, checkY) == targetType)
                {
                    return true;
                }
            }
        }

        return false;
    }

    private bool IsSurroundedByOcean4Directions(MapData map, int x, int y)
    {
        if (x <= 0 || x >= map.Width - 1 || y <= 0 || y >= map.Height - 1)
        {
            return false;
        }

        return map.GetCell(x, y - 1) == Ocean &&
               map.GetCell(x, y + 1) == Ocean &&
               map.GetCell(x - 1, y) == Ocean &&
               map.GetCell(x + 1, y) == Ocean;
    }

    public MapData ModerateTemperatureEdges(MapData source)
    {
        MapData result = new MapData(source.Width, source.Height);

        for (int y = 0; y < source.Height; y++)
        {
            for (int x = 0; x < source.Width; x++)
            {
                int cell = source.GetCell(x, y);
                int temp = source.GetTemperature(x, y);

                bool touchesCold = HasNeighborTemperature(source, x, y, Cold);
                bool touchesWarm = HasNeighborTemperature(source, x, y, Warm);

                if (temp == Warm && touchesCold)
                {
                    temp = Moderate;
                }
                else if (temp == Cold && touchesWarm)
                {
                    temp = Moderate;
                }

                result.SetCell(x, y, cell);
                result.SetTemperature(x, y, temp);
            }
        }

        return result;
    }

    private bool HasNeighborTemperature(MapData map, int x, int y, int targetTemp)
    {
        for (int offsetY = -1; offsetY <= 1; offsetY++)
        {
            for (int offsetX = -1; offsetX <= 1; offsetX++)
            {
                if (offsetX == 0 && offsetY == 0)
                {
                    continue;
                }

                int checkX = x + offsetX;
                int checkY = y + offsetY;

                if (checkX < 0 || checkX >= map.Width || checkY < 0 || checkY >= map.Height)
                {
                    continue;
                }

                if (map.GetTemperature(checkX, checkY) == targetTemp)
                {
                    return true;
                }
            }
        }

        return false;
    }
    public MapData MutateTemperatures(MapData source)
    {
        MapData result = new MapData(source.Width, source.Height);

        for (int y = 0; y < source.Height; y++)
        {
            for (int x = 0; x < source.Width; x++)
            {
                int cell = source.GetCell(x, y);
                int temperature = source.GetTemperature(x, y);

                bool touchesCold = HasNeighborTemperature(source, x, y, Cold);
                bool touchesWarm = HasNeighborTemperature(source, x, y, Warm);

                if (temperature == Warm && touchesCold)
                {
                    temperature = random.NextDouble() < 0.25 ? Moderate : Warm;
                }
                else if (temperature == Cold && touchesWarm)
                {
                    temperature = random.NextDouble() < 0.25 ? Moderate : Cold;
                }

                result.SetCell(x, y, cell);
                result.SetTemperature(x, y, temperature);
            }
        }

        return result;
    }
}