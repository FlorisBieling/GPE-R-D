using UnityEngine;
using UnityEngine.InputSystem;

public class MapController : MonoBehaviour
{
    [SerializeField] private BiomeMapGenerator generator;
    [SerializeField] private TextureMapVisualizer visualizer;

    private MapDataOLD currentMap;
    private TextureMapVisualizer.MapDisplayMode currentDisplayMode = TextureMapVisualizer.MapDisplayMode.LandOcean;

    private void Start()
    {
        currentMap = generator.GenerateInitialMap(4, 4, 0.10f);
        Redraw();
    }

    private void Update()
    {
        if (Keyboard.current.digit1Key.wasPressedThisFrame)
        {
            currentMap = generator.GenerateInitialMap(4, 4, 0.10f);
            Redraw();
        }

        if (Keyboard.current.digit2Key.wasPressedThisFrame)
        {
            currentMap = generator.Subdivide(currentMap);
            Redraw();
        }

        if (Keyboard.current.digit3Key.wasPressedThisFrame)
        {
            currentMap = generator.MutateCoast(currentMap);
            Redraw();
        }

        if (Keyboard.current.digit4Key.wasPressedThisFrame)
        {
            currentMap = generator.AddIslandsInOpenOcean(currentMap);
            Redraw();
        }

        if (Keyboard.current.digit5Key.wasPressedThisFrame)
        {
            currentMap = generator.Subdivide(currentMap);
            currentMap = generator.MutateCoast(currentMap);
            currentMap = generator.Subdivide(currentMap);
            currentMap = generator.MutateCoast(currentMap);
            currentMap = generator.MutateCoast(currentMap);
            currentMap = generator.AddIslandsInOpenOcean(currentMap);
            currentMap = generator.GenerateTemperatures(currentMap);
            currentMap = generator.MutateTemperatures(currentMap);
            currentMap = generator.MutateTemperatures(currentMap);
            currentMap = generator.Subdivide(currentMap);
            currentMap = generator.MutateCoast(currentMap);
            currentMap = generator.Subdivide(currentMap);
            currentMap = generator.MutateCoast(currentMap);
            currentMap = generator.ModerateTemperatureEdges(currentMap);

            Redraw();
        }

        if (Keyboard.current.digit6Key.wasPressedThisFrame)
        {
            currentMap = generator.GenerateTemperatures(currentMap);
            Redraw();
        }

        if (Keyboard.current.digit7Key.wasPressedThisFrame)
        {
            currentMap = generator.ModerateTemperatureEdges(currentMap);
            Redraw();
        }

        if (Keyboard.current.digit8Key.wasPressedThisFrame)
        {
            currentMap = generator.MutateTemperatures(currentMap);
            Redraw();
        }

        if (Keyboard.current.tKey.wasPressedThisFrame)
        {
            ToggleDisplayMode();
        }
    }

    private void ToggleDisplayMode()
    {
        if (currentDisplayMode == TextureMapVisualizer.MapDisplayMode.LandOcean)
        {
            currentDisplayMode = TextureMapVisualizer.MapDisplayMode.Temperature;
        }
        else
        {
            currentDisplayMode = TextureMapVisualizer.MapDisplayMode.LandOcean;
        }

        Redraw();
    }

    private void Redraw()
    {
        visualizer.Draw(currentMap, currentDisplayMode);
    }
}