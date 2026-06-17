Shader "Custom/ProceduralBiomeTexturesURP"
{
    Properties
    {
        _ColorMap ("Fallback Biome Color Map", 2D) = "white" {}
        _ControlMapA ("Biome Control Map A", 2D) = "black" {}
        _ControlMapB ("Biome Control Map B", 2D) = "black" {}

        [Header(Water)]
        _WaterTex ("Water Albedo", 2D) = "white" {}
        [Normal] _WaterNormal ("Water Normal", 2D) = "bump" {}
        _WaterSpecular ("Water Specular", 2D) = "black" {}
        _WaterScale ("Water Scale", Float) = 0.12

        [Header(Beach)]
        _BeachTex ("Beach Albedo", 2D) = "white" {}
        [Normal] _BeachNormal ("Beach Normal", 2D) = "bump" {}
        _BeachSpecular ("Beach Specular", 2D) = "black" {}
        _BeachScale ("Beach Scale", Float) = 0.12

        [Header(Plains)]
        _PlainsTex ("Plains Albedo", 2D) = "white" {}
        [Normal] _PlainsNormal ("Plains Normal", 2D) = "bump" {}
        _PlainsSpecular ("Plains Specular", 2D) = "black" {}
        _PlainsScale ("Plains Scale", Float) = 0.12

        [Header(Forest)]
        _ForestTex ("Forest Albedo", 2D) = "white" {}
        [Normal] _ForestNormal ("Forest Normal", 2D) = "bump" {}
        _ForestSpecular ("Forest Specular", 2D) = "black" {}
        _ForestScale ("Forest Scale", Float) = 0.12

        [Header(Desert)]
        _DesertTex ("Desert Albedo", 2D) = "white" {}
        [Normal] _DesertNormal ("Desert Normal", 2D) = "bump" {}
        _DesertSpecular ("Desert Specular", 2D) = "black" {}
        _DesertScale ("Desert Scale", Float) = 0.12

        [Header(Mountain)]
        _MountainTex ("Mountain Albedo", 2D) = "white" {}
        [Normal] _MountainNormal ("Mountain Normal", 2D) = "bump" {}
        _MountainSpecular ("Mountain Specular", 2D) = "black" {}
        _MountainScale ("Mountain Scale", Float) = 0.12

        [Header(Snow)]
        _SnowTex ("Snow Albedo", 2D) = "white" {}
        [Normal] _SnowNormal ("Snow Normal", 2D) = "bump" {}
        _SnowSpecular ("Snow Specular", 2D) = "black" {}
        _SnowScale ("Snow Scale", Float) = 0.12

        [Header(Surface)]
        _NormalStrength ("Normal Strength", Range(0, 2)) = 1
        _SpecularStrength ("Specular Strength", Range(0, 2)) = 0.5
        _Smoothness ("Smoothness", Range(0.01, 1)) = 0.3
        _AmbientStrength ("Ambient Strength", Range(0, 1)) = 0.35
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

        Pass
        {
            Name "Forward"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_ColorMap);
            TEXTURE2D(_ControlMapA);
            TEXTURE2D(_ControlMapB);

            TEXTURE2D(_WaterTex);
            TEXTURE2D(_WaterNormal);
            TEXTURE2D(_WaterSpecular);

            TEXTURE2D(_BeachTex);
            TEXTURE2D(_BeachNormal);
            TEXTURE2D(_BeachSpecular);

            TEXTURE2D(_PlainsTex);
            TEXTURE2D(_PlainsNormal);
            TEXTURE2D(_PlainsSpecular);

            TEXTURE2D(_ForestTex);
            TEXTURE2D(_ForestNormal);
            TEXTURE2D(_ForestSpecular);

            TEXTURE2D(_DesertTex);
            TEXTURE2D(_DesertNormal);
            TEXTURE2D(_DesertSpecular);

            TEXTURE2D(_MountainTex);
            TEXTURE2D(_MountainNormal);
            TEXTURE2D(_MountainSpecular);

            TEXTURE2D(_SnowTex);
            TEXTURE2D(_SnowNormal);
            TEXTURE2D(_SnowSpecular);

            SAMPLER(sampler_linear_repeat);
            SAMPLER(sampler_linear_clamp);

            CBUFFER_START(UnityPerMaterial)
                float4 _ColorMap_ST;
                float4 _ControlMapA_ST;
                float4 _ControlMapB_ST;

                float _WaterScale;
                float _BeachScale;
                float _PlainsScale;
                float _ForestScale;
                float _DesertScale;
                float _MountainScale;
                float _SnowScale;

                float _NormalStrength;
                float _SpecularStrength;
                float _Smoothness;
                float _AmbientStrength;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float2 uvColor : TEXCOORD2;
                float2 uvControlA : TEXCOORD3;
                float2 uvControlB : TEXCOORD4;
                float fogFactor : TEXCOORD5;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positions = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normals = GetVertexNormalInputs(input.normalOS);

                output.positionCS = positions.positionCS;
                output.positionWS = positions.positionWS;
                output.normalWS = normals.normalWS;
                output.uvColor = TRANSFORM_TEX(input.uv, _ColorMap);
                output.uvControlA = TRANSFORM_TEX(input.uv, _ControlMapA);
                output.uvControlB = TRANSFORM_TEX(input.uv, _ControlMapB);
                output.fogFactor = ComputeFogFactor(positions.positionCS.z);

                return output;
            }

            float3 SampleAlbedo(TEXTURE2D_PARAM(textureMap, samplerMap), float2 uv)
            {
                return SAMPLE_TEXTURE2D(textureMap, samplerMap, uv).rgb;
            }

            float3 SampleNormalMap(TEXTURE2D_PARAM(textureMap, samplerMap), float2 uv)
            {
                float3 normalTS = UnpackNormal(
                    SAMPLE_TEXTURE2D(textureMap, samplerMap, uv)
                );

                normalTS.xy *= _NormalStrength;
                return normalize(normalTS);
            }

            float3 SampleSpecularMap(TEXTURE2D_PARAM(textureMap, samplerMap), float2 uv)
            {
                return SAMPLE_TEXTURE2D(textureMap, samplerMap, uv).rgb
                    * _SpecularStrength;
            }

            float3 TangentToWorld(float3 normalTS, float3 baseNormalWS)
            {
                float3 normalWS = normalize(baseNormalWS);

                float3 tangentWS = float3(1, 0, 0);
                tangentWS = normalize(
                    tangentWS - normalWS * dot(tangentWS, normalWS)
                );

                if (dot(tangentWS, tangentWS) < 0.001)
                {
                    tangentWS = normalize(
                        float3(0, 0, 1) -
                        normalWS * dot(float3(0, 0, 1), normalWS)
                    );
                }

                float3 bitangentWS = normalize(cross(normalWS, tangentWS));

                return normalize(
                    tangentWS * normalTS.x +
                    bitangentWS * normalTS.y +
                    normalWS * normalTS.z
                );
            }

            half4 frag(Varyings input) : SV_Target
            {
                float4 controlA = SAMPLE_TEXTURE2D(
                    _ControlMapA,
                    sampler_linear_clamp,
                    input.uvControlA
                );

                float4 controlB = SAMPLE_TEXTURE2D(
                    _ControlMapB,
                    sampler_linear_clamp,
                    input.uvControlB
                );

                float waterWeight = controlA.r;
                float beachWeight = controlA.g;
                float plainsWeight = controlA.b;
                float forestWeight = controlA.a;
                float desertWeight = controlB.r;
                float mountainWeight = controlB.g;
                float snowWeight = controlB.b;

                float totalWeight = max(
                    0.0001,
                    waterWeight + beachWeight + plainsWeight +
                    forestWeight + desertWeight + mountainWeight +
                    snowWeight
                );

                float2 worldXZ = input.positionWS.xz;

                float2 waterUV = worldXZ * _WaterScale;
                float2 beachUV = worldXZ * _BeachScale;
                float2 plainsUV = worldXZ * _PlainsScale;
                float2 forestUV = worldXZ * _ForestScale;
                float2 desertUV = worldXZ * _DesertScale;
                float2 mountainUV = worldXZ * _MountainScale;
                float2 snowUV = worldXZ * _SnowScale;

                float3 albedo = 0;
                albedo += SampleAlbedo(TEXTURE2D_ARGS(_WaterTex, sampler_linear_repeat), waterUV) * waterWeight;
                albedo += SampleAlbedo(TEXTURE2D_ARGS(_BeachTex, sampler_linear_repeat), beachUV) * beachWeight;
                albedo += SampleAlbedo(TEXTURE2D_ARGS(_PlainsTex, sampler_linear_repeat), plainsUV) * plainsWeight;
                albedo += SampleAlbedo(TEXTURE2D_ARGS(_ForestTex, sampler_linear_repeat), forestUV) * forestWeight;
                albedo += SampleAlbedo(TEXTURE2D_ARGS(_DesertTex, sampler_linear_repeat), desertUV) * desertWeight;
                albedo += SampleAlbedo(TEXTURE2D_ARGS(_MountainTex, sampler_linear_repeat), mountainUV) * mountainWeight;
                albedo += SampleAlbedo(TEXTURE2D_ARGS(_SnowTex, sampler_linear_repeat), snowUV) * snowWeight;
                albedo /= totalWeight;

                float3 normalTS = 0;
                normalTS += SampleNormalMap(TEXTURE2D_ARGS(_WaterNormal, sampler_linear_repeat), waterUV) * waterWeight;
                normalTS += SampleNormalMap(TEXTURE2D_ARGS(_BeachNormal, sampler_linear_repeat), beachUV) * beachWeight;
                normalTS += SampleNormalMap(TEXTURE2D_ARGS(_PlainsNormal, sampler_linear_repeat), plainsUV) * plainsWeight;
                normalTS += SampleNormalMap(TEXTURE2D_ARGS(_ForestNormal, sampler_linear_repeat), forestUV) * forestWeight;
                normalTS += SampleNormalMap(TEXTURE2D_ARGS(_DesertNormal, sampler_linear_repeat), desertUV) * desertWeight;
                normalTS += SampleNormalMap(TEXTURE2D_ARGS(_MountainNormal, sampler_linear_repeat), mountainUV) * mountainWeight;
                normalTS += SampleNormalMap(TEXTURE2D_ARGS(_SnowNormal, sampler_linear_repeat), snowUV) * snowWeight;
                normalTS = normalize(normalTS / totalWeight);

                float3 specular = 0;
                specular += SampleSpecularMap(TEXTURE2D_ARGS(_WaterSpecular, sampler_linear_repeat), waterUV) * waterWeight;
                specular += SampleSpecularMap(TEXTURE2D_ARGS(_BeachSpecular, sampler_linear_repeat), beachUV) * beachWeight;
                specular += SampleSpecularMap(TEXTURE2D_ARGS(_PlainsSpecular, sampler_linear_repeat), plainsUV) * plainsWeight;
                specular += SampleSpecularMap(TEXTURE2D_ARGS(_ForestSpecular, sampler_linear_repeat), forestUV) * forestWeight;
                specular += SampleSpecularMap(TEXTURE2D_ARGS(_DesertSpecular, sampler_linear_repeat), desertUV) * desertWeight;
                specular += SampleSpecularMap(TEXTURE2D_ARGS(_MountainSpecular, sampler_linear_repeat), mountainUV) * mountainWeight;
                specular += SampleSpecularMap(TEXTURE2D_ARGS(_SnowSpecular, sampler_linear_repeat), snowUV) * snowWeight;
                specular /= totalWeight;

                float3 normalWS = TangentToWorld(
                    normalTS,
                    input.normalWS
                );

                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                Light mainLight = GetMainLight(shadowCoord);

                float3 lightDirection = normalize(mainLight.direction);
                float3 viewDirection = SafeNormalize(
                    GetWorldSpaceViewDir(input.positionWS)
                );
                float3 halfDirection = SafeNormalize(
                    lightDirection + viewDirection
                );

                float diffuse = saturate(
                    dot(normalWS, lightDirection)
                );

                float specularExponent = lerp(
                    8.0,
                    128.0,
                    _Smoothness
                );

                float specularHighlight = pow(
                    saturate(dot(normalWS, halfDirection)),
                    specularExponent
                );

                float attenuation =
                    mainLight.distanceAttenuation *
                    mainLight.shadowAttenuation;

                float3 directLighting =
                    albedo *
                    mainLight.color *
                    diffuse *
                    attenuation;

                float3 specularLighting =
                    specular *
                    mainLight.color *
                    specularHighlight *
                    attenuation;

                float3 ambientLighting =
                    SampleSH(normalWS) *
                    albedo *
                    _AmbientStrength;

                float3 finalColor =
                    ambientLighting +
                    directLighting +
                    specularLighting;

                finalColor = MixFog(
                    finalColor,
                    input.fogFactor
                );

                return half4(finalColor, 1);
            }
            ENDHLSL
        }

        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/DepthOnly"
    }

    FallBack Off
}
