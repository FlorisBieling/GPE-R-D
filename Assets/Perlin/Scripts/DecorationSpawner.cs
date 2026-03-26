using UnityEngine;

public class DecorationSpawner : MonoBehaviour
{
    [SerializeField] private MapGenerator mapGenerator;
    [SerializeField] private Transform decorationParent;
    [SerializeField] private float tileSize = 1f;
    [SerializeField] private float yOffset = 0f;
    [SerializeField] private bool spawnOnStart = true;

    private void Awake()
    {
        if (mapGenerator == null)
        {
            mapGenerator = GetComponent<MapGenerator>();
        }
    }

    private void Start()
    {
        if (spawnOnStart)
        {
            SpawnDecorations();
        }
    }

    public void SpawnDecorations()
    {
        if (mapGenerator == null)
        {
            Debug.LogError("No MapGenerator reference found.");
            return;
        }

        MapData mapData = mapGenerator.GetMapData(Vector2.zero);

        for (int y = 0; y < MapGenerator.mapChunkSize; y++)
        {
            for (int x = 0; x < MapGenerator.mapChunkSize; x++)
            {
                float currentHeight = mapData.heightMap[x, y];
                float currentTemperature = mapData.temperatureMap[x, y];

                BiomeType biome = mapGenerator.GetBiome(currentHeight, currentTemperature);

                if (biome.decorationPrefabs == null || biome.decorationPrefabs.Length == 0)
                {
                    continue;
                }

                if (Random.value > biome.decorationChance)
                {
                    continue;
                }

                GameObject prefabToSpawn = biome.decorationPrefabs[Random.Range(0, biome.decorationPrefabs.Length)];

                Vector3 randomOffset = new Vector3(
                    Random.Range(-0.4f, 0.4f),
                    0f,
                    Random.Range(-0.4f, 0.4f)
                );

                Vector3 spawnPosition = new Vector3(
                    x * tileSize,
                    yOffset,
                    y * tileSize
                ) + randomOffset;

                Quaternion randomRotation = Quaternion.Euler(0f, Random.Range(0f, 360f), 0f);

                Instantiate(prefabToSpawn, spawnPosition, randomRotation, decorationParent);
            }
        }
    }
}