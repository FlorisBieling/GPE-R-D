using UnityEngine;
using System.Collections;

public class MapDisplay : MonoBehaviour
{

    public Renderer textureRender;
    public MeshFilter meshFilter;
    public MeshRenderer meshRenderer;

    public void DrawTexture(Texture2D texture)
    {
        textureRender.sharedMaterial.mainTexture = texture;
    }

    public void DrawMesh(MeshData meshData, Texture2D texture)
    {
        meshFilter.sharedMesh = meshData.CreateMesh();
        meshRenderer.sharedMaterial.mainTexture = texture;
        meshRenderer.sharedMaterial.SetTexture("_ColorMap", texture);
    }

    public void DrawMesh(MeshData meshData, Texture2D colorTexture, Texture2D controlTextureA, Texture2D controlTextureB)
    {
        meshFilter.sharedMesh = meshData.CreateMesh();
        meshRenderer.sharedMaterial.mainTexture = colorTexture;
        meshRenderer.sharedMaterial.SetTexture("_ColorMap", colorTexture);
        meshRenderer.sharedMaterial.SetTexture("_ControlMapA", controlTextureA);
        meshRenderer.sharedMaterial.SetTexture("_ControlMapB", controlTextureB);
    }
}