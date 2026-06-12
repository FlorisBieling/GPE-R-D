using System.Collections.Generic;
using UnityEngine;

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

        if ((viewerPositionOld - viewerPosition).sqrMagnitude > sqrViewerMoveThresholdForChunkUpdate)
        {
            viewerPositionOld = viewerPosition;
            UpdateVisibleChunks();
        }

        for (int i = 0; i < terrainChunksVisibleLastUpdate.Count; i++)
        {
            terrainChunksVisibleLastUpdate[i].UpdateDecorationInstantiation();
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
        const int decorationsPerFrame = 20;

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
        int currentLODIndex = -1;

        GameObject decorationObject;
        Transform decorationParent;

        bool decorationDataRequested;
        bool decorationDataReceived;
        bool decorationsFullyInstantiated;
        DecorationSpawnData[] pendingDecorationData;
        int nextDecorationSpawnIndex;

        public TerrainChunk(Vector2 coord, int size, LODInfo[] detailLevels, Transform parent, Material material)
        {
            this.detailLevels = detailLevels;

            position = coord * size;
            bounds = new Bounds(position, Vector2.one * size);

            Vector3 positionV3 = new Vector3(position.x, 0f, position.y);

            meshObject = new GameObject("Terrain Chunk");
            meshRenderer = meshObject.AddComponent<MeshRenderer>();
            meshFilter = meshObject.AddComponent<MeshFilter>();
            meshRenderer.material = material;

            meshObject.transform.position = positionV3 * scale;
            meshObject.transform.parent = parent;
            meshObject.transform.localScale = Vector3.one * scale;

            decorationObject = new GameObject("Decorations");
            decorationParent = decorationObject.transform;
            decorationParent.parent = meshObject.transform;
            decorationParent.localPosition = Vector3.zero;
            decorationParent.localRotation = Quaternion.identity;
            decorationParent.localScale = Vector3.one;

            SetVisible(false);

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

            Texture2D colorTexture = TextureGenerator.TextureFromColorMap(mapData.colorMap, MapGenerator.mapChunkSize, MapGenerator.mapChunkSize);
            Texture2D controlTextureA = TextureGenerator.TextureFromColorMap(mapData.biomeControlMapA, MapGenerator.mapChunkSize, MapGenerator.mapChunkSize);
            Texture2D controlTextureB = TextureGenerator.TextureFromColorMap(mapData.biomeControlMapB, MapGenerator.mapChunkSize, MapGenerator.mapChunkSize);

            meshRenderer.material.mainTexture = colorTexture;
            meshRenderer.material.SetTexture("_ColorMap", colorTexture);
            meshRenderer.material.SetTexture("_ControlMapA", controlTextureA);
            meshRenderer.material.SetTexture("_ControlMapB", controlTextureB);

            if (!decorationDataRequested)
            {
                decorationDataRequested = true;
                mapGenerator.RequestDecorationData(mapData, position, OnDecorationDataReceived);
            }

            UpdateTerrainChunk();
        }

        void OnDecorationDataReceived(DecorationSpawnData[] decorationData)
        {
            pendingDecorationData = decorationData;
            decorationDataReceived = true;
            nextDecorationSpawnIndex = 0;
        }

        public void UpdateTerrainChunk()
        {
            if (!mapDataRecieved)
            {
                return;
            }

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

                currentLODIndex = lodIndex;
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

        public void UpdateDecorationInstantiation()
        {
            if (!mapDataRecieved || !decorationDataReceived || decorationsFullyInstantiated)
            {
                return;
            }

            if (!meshObject.activeSelf || currentLODIndex != 0)
            {
                return;
            }

            int spawnedThisFrame = 0;

            while (nextDecorationSpawnIndex < pendingDecorationData.Length && spawnedThisFrame < decorationsPerFrame)
            {
                DecorationSpawnData spawnData = pendingDecorationData[nextDecorationSpawnIndex];
                nextDecorationSpawnIndex++;

                GameObject prefab = GetPrefabForSpawnData(spawnData);

                if (prefab == null)
                {
                    continue;
                }

                float localY = mapGenerator.GetMeshHeight(spawnData.heightValue);

                Vector3 localPosition = new Vector3(
                    spawnData.localX,
                    localY,
                    spawnData.localZ
                );

                Quaternion localRotation = Quaternion.Euler(0f, spawnData.rotationY, 0f);

                GameObject spawnedObject = Object.Instantiate(prefab, decorationParent);
                spawnedObject.transform.localPosition = localPosition;
                spawnedObject.transform.localRotation = localRotation;
                spawnedObject.transform.localScale = Vector3.one * spawnData.uniformScale;

                spawnedThisFrame++;
            }

            if (nextDecorationSpawnIndex >= pendingDecorationData.Length)
            {
                decorationsFullyInstantiated = true;
                pendingDecorationData = null;
            }
        }

        GameObject GetPrefabForSpawnData(DecorationSpawnData spawnData)
        {
            if (spawnData.tileX < 0 || spawnData.tileX >= MapGenerator.mapChunkSize || spawnData.tileY < 0 || spawnData.tileY >= MapGenerator.mapChunkSize)
            {
                return null;
            }

            float currentHeight = mapData.heightMap[spawnData.tileX, spawnData.tileY];
            float currentTemperature = mapData.temperatureMap[spawnData.tileX, spawnData.tileY];
            float currentMoisture = mapData.moistureMap[spawnData.tileX, spawnData.tileY];

            BiomeType biome = mapGenerator.GetBiome(currentHeight, currentTemperature, currentMoisture);

            if (biome.decorationLayers == null || spawnData.layerIndex < 0 || spawnData.layerIndex >= biome.decorationLayers.Length)
            {
                return null;
            }

            DecorationLayer layer = biome.decorationLayers[spawnData.layerIndex];

            if (layer.prefabs == null || spawnData.prefabIndex < 0 || spawnData.prefabIndex >= layer.prefabs.Length)
            {
                return null;
            }

            return layer.prefabs[spawnData.prefabIndex];
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
}