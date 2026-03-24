public class MapDataOLD
{
    public int Width { get; }
    public int Height { get; }
    public int[,] Cells { get; }
    public int[,] Temperatures { get; }

    public MapDataOLD(int width, int height)
    {
        Width = width;
        Height = height;
        Cells = new int[width, height];
        Temperatures = new int[width, height];
    }

    public int GetCell(int x, int y)
    {
        return Cells[x, y];
    }

    public void SetCell(int x, int y, int value)
    {
        Cells[x, y] = value;
    }

    public int GetTemperature(int x, int y)
    {
        return Temperatures[x, y];
    }

    public void SetTemperature(int x, int y, int value)
    {
        Temperatures[x, y] = value;
    }
}