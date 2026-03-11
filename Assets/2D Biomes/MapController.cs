using UnityEngine;
using UnityEngine.InputSystem;

public class MapController : MonoBehaviour
{
    [SerializeField] private BiomeMapGenerator generator;
    [SerializeField] private TextureMapVisualizer visualizer;

    private MapData currentMap;

    private void Start()
    {
        currentMap = generator.GenerateInitialMap(4, 4, 0.10f);
        visualizer.Draw(currentMap);
    }

    private void Update()
    {
        if (Keyboard.current.digit1Key.wasPressedThisFrame)
        {
            currentMap = generator.GenerateInitialMap(4, 4, 0.10f);
            visualizer.Draw(currentMap);
        }

        if (Keyboard.current.digit2Key.wasPressedThisFrame)
        {
            currentMap = generator.Subdivide(currentMap);
            visualizer.Draw(currentMap);
        }

        if (Keyboard.current.digit3Key.wasPressedThisFrame)
        {
            currentMap = generator.MutateCoast(currentMap);
            visualizer.Draw(currentMap);
        }

        if (Keyboard.current.digit4Key.wasPressedThisFrame)
        {
            currentMap = generator.Subdivide(currentMap);
            currentMap = generator.MutateCoast(currentMap);
            currentMap = generator.Subdivide(currentMap);
            currentMap = generator.MutateCoast(currentMap);
            currentMap = generator.MutateCoast(currentMap);
            currentMap = generator.MutateCoast(currentMap);
            visualizer.Draw(currentMap);
        }
    }
}