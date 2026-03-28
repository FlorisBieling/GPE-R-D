using UnityEngine;
using System.Collections.Generic;

public class EndlessTerrain : MonoBehaviour
{
    const float scale = 1f;
        
    const float viewerMoveThresholdForChunkUpdate = 25f;
    const float sqrViewerMoveThresholdForChunkUpdate = viewerMoveThresholdForChunkUpdate * viewerMoveThresholdForChunkUpdate;

    public LODInfo[] detailLevels;
    public static float maxViewDistance;

    public Transform viewer;
    public Material mapMaterial;

    public static Vector2 viewerPosition;
    Vector2 viewerPositionOld;
    static MapGenerator mapGenerator;
    int chunkSize;
    int chunksVisibleInViewDst;

    Dictionary<Vector2, TerrainChunk> terrainChunkDictionary = new Dictionary<Vector2, TerrainChunk>();
    static List<TerrainChunk> terrainChunksVisibleLastUpdate = new List<TerrainChunk>();

    void Start()
    {
        mapGenerator = FindObjectOfType<MapGenerator>();

        maxViewDistance = detailLevels[detailLevels.Length - 1].visibleDistanceThreshold;
        chunkSize = MapGenerator.mapChunkSize - 1;
        chunksVisibleInViewDst = Mathf.RoundToInt(maxViewDistance / chunkSize);
        UpdateVisibleChunks();
    }

    void Update()
    {
        viewerPosition = new Vector2(viewer.position.x, viewer.position.z) / scale;

        if ((viewerPositionOld-viewerPosition).sqrMagnitude > sqrViewerMoveThresholdForChunkUpdate)
        {
            viewerPositionOld = viewerPosition;
            UpdateVisibleChunks();
        }
    }

    void UpdateVisibleChunks()
    {

        for (int i = 0; i < terrainChunksVisibleLastUpdate.Count; i++)
        {
            terrainChunksVisibleLastUpdate[i].SetVisible(false);
        }
        terrainChunksVisibleLastUpdate.Clear();

        int currentChunkCoordX = Mathf.RoundToInt(viewerPosition.x / chunkSize);
        int currentChunkCoordY = Mathf.RoundToInt(viewerPosition.y / chunkSize);

        for (int yOffset = -chunksVisibleInViewDst; yOffset <= chunksVisibleInViewDst; yOffset++)
        {
            for (int xOffset = -chunksVisibleInViewDst; xOffset <= chunksVisibleInViewDst; xOffset++)
            {
                Vector2 viewedChunkCoord = new Vector2(currentChunkCoordX + xOffset, currentChunkCoordY + yOffset);

                if (terrainChunkDictionary.ContainsKey(viewedChunkCoord))
                {
                    terrainChunkDictionary[viewedChunkCoord].UpdateTerrainChunk();

                }
                else
                {
                    terrainChunkDictionary.Add(viewedChunkCoord, new TerrainChunk(viewedChunkCoord, chunkSize, detailLevels, transform, mapMaterial));
                }
            }
        }
    }

    public class TerrainChunk
    {
        GameObject meshObject;
        Vector2 position;
        Bounds bounds;

        MeshRenderer meshRenderer;
        MeshFilter meshFilter;

        LODInfo[] detailLevels;
        LODMesh[] lodMeshes;

        MapData mapData;
        bool mapDataRecieved;
        int previousLODIndex = -1;

        GameObject decorationObject;
        Transform decorationParent;
        bool decorationsSpawned;

        public TerrainChunk(Vector2 coord, int size, LODInfo[] detailLevels, Transform parent, Material material)
        {
            this.detailLevels = detailLevels;

            position = coord * size;
            bounds = new Bounds(position, Vector2.one * size);
            Vector3 positionV3 = new Vector3(position.x, 0, position.y);

            meshObject = new GameObject("Terrain Chunk");
            meshRenderer = meshObject.AddComponent<MeshRenderer>();
            meshFilter = meshObject.AddComponent<MeshFilter>();
            meshRenderer.material = material;

            meshObject.transform.position = positionV3 * scale;
            meshObject.transform.parent = parent; 
            meshObject.transform.localScale = Vector3.one * scale;
            SetVisible(false);

            decorationObject = new GameObject("Decorations");
            decorationParent = decorationObject.transform;
            decorationParent.parent = meshObject.transform;
            decorationParent.localPosition = Vector3.zero;
            decorationParent.localRotation = Quaternion.identity;
            decorationParent.localScale = Vector3.one;

            lodMeshes = new LODMesh[detailLevels.Length];
            for (int i = 0; i < detailLevels.Length; i++)
            {
                lodMeshes[i] = new LODMesh(detailLevels[i].lod, UpdateTerrainChunk);
            }

            mapGenerator.RequestMapData(position, OnMapDataReceived);
        }

        void OnMapDataReceived(MapData mapData)
        {
            this.mapData = mapData;
            mapDataRecieved = true;

            Texture2D texture = TextureGenerator.TextureFromColorMap(mapData.colorMap, MapGenerator.mapChunkSize, MapGenerator.mapChunkSize);
            meshRenderer.material.mainTexture = texture;

            SpawnDecorations();

            UpdateTerrainChunk();
        }

        void OnMeshDataReceived(MeshData meshData)
        {
            meshFilter.mesh = meshData.CreateMesh();
        }

        public void UpdateTerrainChunk()
        {
            if (mapDataRecieved)
            {
                float viewerDstFromNearestEdge = Mathf.Sqrt(bounds.SqrDistance(viewerPosition));
                bool visible = viewerDstFromNearestEdge <= maxViewDistance;

                if (visible)
                {
                    int lodIndex = 0;

                    for (int i = 0; i < detailLevels.Length - 1; i++)
                    {
                        if (viewerDstFromNearestEdge > detailLevels[i].visibleDistanceThreshold)
                        {
                            lodIndex = i + 1;
                        }
                        else
                        {
                            break;
                        }
                    }

                    decorationObject.SetActive(lodIndex == 0);

                    if (lodIndex != previousLODIndex)
                    {
                        LODMesh lodMesh = lodMeshes[lodIndex];
                        if (lodMesh.hasMesh)
                        {
                            previousLODIndex = lodIndex;
                            meshFilter.mesh = lodMesh.mesh;
                        }
                        else if (!lodMesh.hasRequestedMesh)
                        {
                            lodMesh.RequestMesh(mapData);
                        }
                    }

                    terrainChunksVisibleLastUpdate.Add(this);
                }
                SetVisible(visible);
            }
        }

        int GetMaxLayerCount()
        {
            int size = MapGenerator.mapChunkSize;
            int maxLayerCount = 0;

            for (int y = 0; y < size; y++)
            {
                for (int x = 0; x < size; x++)
                {
                    float currentHeight = mapData.heightMap[x, y];
                    float currentTemperature = mapData.temperatureMap[x, y];

                    BiomeType biome = mapGenerator.GetBiome(currentHeight, currentTemperature);

                    if (biome.decorationLayers != null && biome.decorationLayers.Length > maxLayerCount)
                    {
                        maxLayerCount = biome.decorationLayers.Length;
                    }
                }
            }

            return maxLayerCount;
        }

        float GetNoiseValue(DecorationLayer layer, Vector3 worldPosition)
        {
            float scale = layer.noiseScale <= 0.0001f ? 0.0001f : layer.noiseScale;

            return Mathf.PerlinNoise(
                (worldPosition.x + layer.noiseOffset.x) / scale,
                (worldPosition.z + layer.noiseOffset.y) / scale
            );
        }

        string GetLayerKey(BiomeType biome, DecorationLayer layer, int layerIndex)
        {
            string biomeName = string.IsNullOrWhiteSpace(biome.name) ? "Biome" : biome.name;
            string layerName = string.IsNullOrWhiteSpace(layer.name) ? $"Layer{layerIndex}" : layer.name;
            return biomeName + "_" + layerName;
        }

        void SpawnDecorations()
        {
            if (decorationsSpawned)
            {
                return;
            }

            decorationsSpawned = true;

            int size = MapGenerator.mapChunkSize;
            float topLeftX = (size - 1) / -2f;
            float topLeftZ = (size - 1) / 2f;

            int maxLayerCount = GetMaxLayerCount();
            LayerSpawnCache spawnCache = new LayerSpawnCache();

            for (int layerIndex = 0; layerIndex < maxLayerCount; layerIndex++)
            {
                for (int y = 0; y < size; y++)
                {
                    for (int x = 0; x < size; x++)
                    {
                        float currentHeight = mapData.heightMap[x, y];
                        float currentTemperature = mapData.temperatureMap[x, y];

                        BiomeType biome = mapGenerator.GetBiome(currentHeight, currentTemperature);

                        if (biome.decorationLayers == null || layerIndex >= biome.decorationLayers.Length)
                        {
                            continue;
                        }

                        DecorationLayer layer = biome.decorationLayers[layerIndex];

                        if (layer.prefabs == null || layer.prefabs.Length == 0)
                        {
                            continue;
                        }

                        int attempts = Mathf.Max(1, layer.attemptsPerTile);

                        for (int attempt = 0; attempt < attempts; attempt++)
                        {
                            float offsetX = Random.Range(-layer.randomOffsetRange.x, layer.randomOffsetRange.x);
                            float offsetZ = Random.Range(-layer.randomOffsetRange.y, layer.randomOffsetRange.y);

                            float localX = topLeftX + x + offsetX;
                            float localZ = topLeftZ - y + offsetZ;
                            float localY = mapGenerator.GetMeshHeight(currentHeight);

                            Vector3 localPosition = new Vector3(localX, localY, localZ);
                            Vector3 worldPosition = meshObject.transform.TransformPoint(localPosition);

                            float noiseValue = GetNoiseValue(layer, worldPosition);

                            if (noiseValue < layer.noiseThreshold)
                            {
                                continue;
                            }

                            if (Random.value > layer.spawnChance)
                            {
                                continue;
                            }

                            string layerKey = GetLayerKey(biome, layer, layerIndex);

                            if (!spawnCache.CanSpawn(layerKey, worldPosition, layer.minDistance))
                            {
                                continue;
                            }

                            GameObject prefabToSpawn = layer.prefabs[Random.Range(0, layer.prefabs.Length)];
                            Quaternion localRotation = Quaternion.Euler(0f, Random.Range(0f, 360f), 0f);

                            GameObject spawnedObject = Object.Instantiate(prefabToSpawn, decorationParent);
                            spawnedObject.transform.localPosition = localPosition;
                            spawnedObject.transform.localRotation = localRotation;

                            float minScale = Mathf.Min(layer.randomScaleRange.x, layer.randomScaleRange.y);
                            float maxScale = Mathf.Max(layer.randomScaleRange.x, layer.randomScaleRange.y);
                            float randomScale = Random.Range(minScale, maxScale);
                            spawnedObject.transform.localScale = Vector3.one * randomScale;

                            spawnCache.Register(layerKey, worldPosition);
                        }
                    }
                }
            }
        }

        public void SetVisible(bool visible)
        {
            meshObject.SetActive(visible);
        }

        public bool IsVisible()
        {
            return meshObject.activeSelf;
        }
    }

    class LODMesh
    {
        public Mesh mesh;
        public bool hasRequestedMesh;
        public bool hasMesh;
        int lod;
        System.Action updateCallBack;
        public LODMesh(int lod, System.Action updateCallBack)
        {
            this.lod = lod;
            this.updateCallBack = updateCallBack;
        }

        void OnMeshDataReceived(MeshData meshData)
        {
            mesh = meshData.CreateMesh();
            hasMesh = true;

            updateCallBack();
        }

        public void RequestMesh(MapData mapData)
        {
            hasRequestedMesh = true;
            mapGenerator.RequestMeshData(mapData, lod, OnMeshDataReceived);
        }
    }

    [System.Serializable]
    public struct LODInfo
    {
        public int lod;
        public float visibleDistanceThreshold;
        public LODInfo(int lod, float visibleDistanceThreshold)
        {
            this.lod = lod;
            this.visibleDistanceThreshold = visibleDistanceThreshold;
        }
    }

    class LayerSpawnCache
    {
        Dictionary<string, List<Vector3>> positionsByLayer = new Dictionary<string, List<Vector3>>();

        public bool CanSpawn(string key, Vector3 worldPosition, float minDistance)
        {
            if (minDistance <= 0f)
            {
                return true;
            }

            if (!positionsByLayer.TryGetValue(key, out List<Vector3> positions))
            {
                return true;
            }

            float minDistanceSqr = minDistance * minDistance;

            for (int i = 0; i < positions.Count; i++)
            {
                Vector3 delta = positions[i] - worldPosition;
                delta.y = 0f;

                if (delta.sqrMagnitude < minDistanceSqr)
                {
                    return false;
                }
            }

            return true;
        }

        public void Register(string key, Vector3 worldPosition)
        {
            if (!positionsByLayer.TryGetValue(key, out List<Vector3> positions))
            {
                positions = new List<Vector3>();
                positionsByLayer[key] = positions;
            }

            positions.Add(worldPosition);
        }
    }
}