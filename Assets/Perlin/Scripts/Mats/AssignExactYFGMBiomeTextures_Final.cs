using UnityEditor;
using UnityEngine;

public static class AssignExactYFGMBiomeTexturesFinal
{
    private struct TextureSet
    {
        public string baseName;
        public string albedoProperty;
        public string normalProperty;
        public string specularProperty;

        public TextureSet(
            string baseName,
            string albedoProperty,
            string normalProperty,
            string specularProperty)
        {
            this.baseName = baseName;
            this.albedoProperty = albedoProperty;
            this.normalProperty = normalProperty;
            this.specularProperty = specularProperty;
        }
    }

    private static readonly TextureSet[] Sets =
    {
        new TextureSet(
            "T_YFGM_FrozenGrass",
            "_WaterTex",
            "_WaterNormal",
            "_WaterSpecular"
        ),
        new TextureSet(
            "T_YFGM_Mars",
            "_BeachTex",
            "_BeachNormal",
            "_BeachSpecular"
        ),
        new TextureSet(
            "T_YFGM_Grass06",
            "_PlainsTex",
            "_PlainsNormal",
            "_PlainsSpecular"
        ),
        new TextureSet(
            "T_YFGM_Grass01",
            "_ForestTex",
            "_ForestNormal",
            "_ForestSpecular"
        ),
        new TextureSet(
            "T_YFGM_Dry01",
            "_DesertTex",
            "_DesertNormal",
            "_DesertSpecular"
        ),
        new TextureSet(
            "T_YFGM_GroundStones02",
            "_MountainTex",
            "_MountainNormal",
            "_MountainSpecular"
        )
    };

    [MenuItem("Tools/Procedural Terrain/Assign Final YFGM Textures")]
    private static void Assign()
    {
        Material material = Selection.activeObject as Material;

        if (material == null)
        {
            EditorUtility.DisplayDialog(
                "No material selected",
                "Select MaterialProceduralTerrain first.",
                "OK"
            );
            return;
        }

        if (material.shader == null ||
            material.shader.name != "Custom/ProceduralBiomeTexturesURP")
        {
            EditorUtility.DisplayDialog(
                "Wrong shader",
                "The selected material must use Custom/ProceduralBiomeTexturesURP.",
                "OK"
            );
            return;
        }

        Undo.RecordObject(
            material,
            "Assign final YFGM biome textures"
        );

        foreach (TextureSet set in Sets)
        {
            AssignRequiredTexture(
                material,
                set.baseName + "_d",
                set.albedoProperty
            );

            AssignRequiredTexture(
                material,
                set.baseName + "_n",
                set.normalProperty
            );

            AssignRequiredTexture(
                material,
                set.baseName + "_s",
                set.specularProperty
            );
        }

        AssignSnow(material);

        EditorUtility.SetDirty(material);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        EditorUtility.DisplayDialog(
            "Finished",
            "The exact YFGM textures were assigned. Check the Console for missing files.",
            "OK"
        );
    }

    private static void AssignSnow(Material material)
    {
        Texture snowAlbedo = FindTexture("T_YFGM_Snow_d");
        Texture snowNormal = FindTexture("T_YFGM_Snow_n");
        Texture snowSpecular = FindTexture("T_YFGM_Snow_s");

        material.SetTexture(
            "_SnowTex",
            snowAlbedo != null
                ? snowAlbedo
                : Texture2D.whiteTexture
        );

        material.SetTexture(
            "_SnowNormal",
            snowNormal != null
                ? snowNormal
                : Texture2D.normalTexture
        );

        material.SetTexture(
            "_SnowSpecular",
            snowSpecular != null
                ? snowSpecular
                : Texture2D.blackTexture
        );

        if (snowAlbedo == null)
        {
            Debug.LogWarning(
                "T_YFGM_Snow_d does not exist. Snow uses a white albedo instead."
            );
        }

        if (snowNormal == null)
        {
            Debug.LogWarning(
                "T_YFGM_Snow_n was not found."
            );
        }

        if (snowSpecular == null)
        {
            Debug.LogWarning(
                "T_YFGM_Snow_s does not exist. Snow uses a black specular map instead."
            );
        }
    }

    private static void AssignRequiredTexture(
        Material material,
        string textureName,
        string propertyName)
    {
        Texture texture = FindTexture(textureName);

        if (texture == null)
        {
            Debug.LogError(
                $"Could not find '{textureName}'."
            );
            return;
        }

        material.SetTexture(
            propertyName,
            texture
        );

        Debug.Log(
            $"Assigned '{textureName}' to '{propertyName}'."
        );
    }

    private static Texture FindTexture(string exactName)
    {
        string[] guids = AssetDatabase.FindAssets(
            $"{exactName} t:Texture"
        );

        foreach (string guid in guids)
        {
            string path =
                AssetDatabase.GUIDToAssetPath(guid);

            Texture texture =
                AssetDatabase.LoadAssetAtPath<Texture>(path);

            if (texture != null &&
                texture.name == exactName)
            {
                return texture;
            }
        }

        return null;
    }
}
