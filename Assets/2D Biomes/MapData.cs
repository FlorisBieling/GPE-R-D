public class MapData
{
    public int Width { get; }
    public int Height { get; }
    public int[,] Cells { get; }

    public MapData(int width, int height)
    {
        Width = width;
        Height = height;
        Cells = new int[width, height];
    }

    public int GetCell(int x, int y)
    {
        return Cells[x, y];
    }

    public void SetCell(int x, int y, int value)
    {
        Cells[x, y] = value;
    }
}