Shader "Custom/ProceduralBiomeTexturesURP"
{
    Properties
    {
        _ColorMap ("Fallback Biome Color Map", 2D) = "white" {}
        _ControlMapA ("Biome Control Map A", 2D) = "black" {}
        _ControlMapB ("Biome Control Map B", 2D) = "black" {}

        _WaterTex ("Water Texture", 2D) = "white" {}
        _BeachTex ("Beach Texture", 2D) = "white" {}
        _PlainsTex ("Plains Texture", 2D) = "white" {}
        _ForestTex ("Forest Texture", 2D) = "white" {}
        _DesertTex ("Desert Texture", 2D) = "white" {}
        _MountainTex ("Mountain Texture", 2D) = "white" {}
        _SnowTex ("Snow Texture", 2D) = "white" {}

        _WaterTint ("Water Tint", Color) = (0.1, 0.45, 0.75, 1)
        _BeachTint ("Beach Tint", Color) = (0.82, 0.72, 0.48, 1)
        _PlainsTint ("Plains Tint", Color) = (0.35, 0.62, 0.25, 1)
        _ForestTint ("Forest Tint", Color) = (0.13, 0.34, 0.16, 1)
        _DesertTint ("Desert Tint", Color) = (0.78, 0.56, 0.28, 1)
        _MountainTint ("Mountain Tint", Color) = (0.42, 0.39, 0.35, 1)
        _SnowTint ("Snow Tint", Color) = (0.94, 0.96, 1.0, 1)

        _WaterScale ("Water Scale", Float) = 0.10
        _BeachScale ("Beach Scale", Float) = 0.18
        _PlainsScale ("Plains Scale", Float) = 0.16
        _ForestScale ("Forest Scale", Float) = 0.18
        _DesertScale ("Desert Scale", Float) = 0.15
        _MountainScale ("Mountain Scale", Float) = 0.14
        _SnowScale ("Snow Scale", Float) = 0.16

        _TextureStrength ("Texture Strength", Range(0, 1)) = 1
        _FallbackColorStrength ("Fallback Color Strength", Range(0, 1)) = 0.2
        _DetailStrength ("Extra Detail Strength", Range(0, 1)) = 0.18
        _DetailScale ("Extra Detail Scale", Float) = 0.8
        _FakeLightStrength ("Fake Light Strength", Range(0, 1)) = 0.35
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
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_ColorMap); SAMPLER(sampler_ColorMap);
            TEXTURE2D(_ControlMapA); SAMPLER(sampler_ControlMapA);
            TEXTURE2D(_ControlMapB); SAMPLER(sampler_ControlMapB);
            TEXTURE2D(_WaterTex); SAMPLER(sampler_WaterTex);
            TEXTURE2D(_BeachTex); SAMPLER(sampler_BeachTex);
            TEXTURE2D(_PlainsTex); SAMPLER(sampler_PlainsTex);
            TEXTURE2D(_ForestTex); SAMPLER(sampler_ForestTex);
            TEXTURE2D(_DesertTex); SAMPLER(sampler_DesertTex);
            TEXTURE2D(_MountainTex); SAMPLER(sampler_MountainTex);
            TEXTURE2D(_SnowTex); SAMPLER(sampler_SnowTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _ColorMap_ST;
                float4 _ControlMapA_ST;
                float4 _ControlMapB_ST;
                float4 _WaterTex_ST;
                float4 _BeachTex_ST;
                float4 _PlainsTex_ST;
                float4 _ForestTex_ST;
                float4 _DesertTex_ST;
                float4 _MountainTex_ST;
                float4 _SnowTex_ST;
                float4 _WaterTint;
                float4 _BeachTint;
                float4 _PlainsTint;
                float4 _ForestTint;
                float4 _DesertTint;
                float4 _MountainTint;
                float4 _SnowTint;
                float _WaterScale;
                float _BeachScale;
                float _PlainsScale;
                float _ForestScale;
                float _DesertScale;
                float _MountainScale;
                float _SnowScale;
                float _TextureStrength;
                float _FallbackColorStrength;
                float _DetailStrength;
                float _DetailScale;
                float _FakeLightStrength;
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
                float3 worldPos : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float2 uvColor : TEXCOORD2;
                float2 uvControlA : TEXCOORD3;
                float2 uvControlB : TEXCOORD4;
            };

            float Hash21(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }

            float ValueNoise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float a = Hash21(i);
                float b = Hash21(i + float2(1, 0));
                float c = Hash21(i + float2(0, 1));
                float d = Hash21(i + float2(1, 1));
                float2 u = f * f * (3.0 - 2.0 * f);
                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            float FractalNoise(float2 p)
            {
                float value = 0;
                float amplitude = 0.5;
                value += ValueNoise(p) * amplitude;
                p *= 2.03;
                amplitude *= 0.5;
                value += ValueNoise(p) * amplitude;
                p *= 2.01;
                amplitude *= 0.5;
                value += ValueNoise(p) * amplitude;
                return saturate(value);
            }

            float3 SampleBiomeTexture(TEXTURE2D_PARAM(tex, samplerTex), float2 worldUV, float scale, float4 tint)
            {
                float safeScale = max(0.0001, scale);
                float3 textureColor = SAMPLE_TEXTURE2D(tex, samplerTex, worldUV * safeScale).rgb;
                float3 tintedColor = textureColor * tint.rgb;
                return lerp(tint.rgb, tintedColor, _TextureStrength);
            }

            Varyings vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
                output.positionCS = positionInputs.positionCS;
                output.worldPos = positionInputs.positionWS;
                output.normalWS = normalInputs.normalWS;
                output.uvColor = TRANSFORM_TEX(input.uv, _ColorMap);
                output.uvControlA = TRANSFORM_TEX(input.uv, _ControlMapA);
                output.uvControlB = TRANSFORM_TEX(input.uv, _ControlMapB);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float2 worldUV = input.worldPos.xz;
                float3 fallbackColor = SAMPLE_TEXTURE2D(_ColorMap, sampler_ColorMap, input.uvColor).rgb;
                float4 controlA = SAMPLE_TEXTURE2D(_ControlMapA, sampler_ControlMapA, input.uvControlA);
                float4 controlB = SAMPLE_TEXTURE2D(_ControlMapB, sampler_ControlMapB, input.uvControlB);

                float waterWeight = controlA.r;
                float beachWeight = controlA.g;
                float plainsWeight = controlA.b;
                float forestWeight = controlA.a;
                float desertWeight = controlB.r;
                float mountainWeight = controlB.g;
                float snowWeight = controlB.b;

                float totalWeight = max(0.0001, waterWeight + beachWeight + plainsWeight + forestWeight + desertWeight + mountainWeight + snowWeight);

                float3 waterColor = SampleBiomeTexture(TEXTURE2D_ARGS(_WaterTex, sampler_WaterTex), worldUV, _WaterScale, _WaterTint);
                float3 beachColor = SampleBiomeTexture(TEXTURE2D_ARGS(_BeachTex, sampler_BeachTex), worldUV, _BeachScale, _BeachTint);
                float3 plainsColor = SampleBiomeTexture(TEXTURE2D_ARGS(_PlainsTex, sampler_PlainsTex), worldUV, _PlainsScale, _PlainsTint);
                float3 forestColor = SampleBiomeTexture(TEXTURE2D_ARGS(_ForestTex, sampler_ForestTex), worldUV, _ForestScale, _ForestTint);
                float3 desertColor = SampleBiomeTexture(TEXTURE2D_ARGS(_DesertTex, sampler_DesertTex), worldUV, _DesertScale, _DesertTint);
                float3 mountainColor = SampleBiomeTexture(TEXTURE2D_ARGS(_MountainTex, sampler_MountainTex), worldUV, _MountainScale, _MountainTint);
                float3 snowColor = SampleBiomeTexture(TEXTURE2D_ARGS(_SnowTex, sampler_SnowTex), worldUV, _SnowScale, _SnowTint);

                float3 finalColor = 0;
                finalColor += waterColor * waterWeight;
                finalColor += beachColor * beachWeight;
                finalColor += plainsColor * plainsWeight;
                finalColor += forestColor * forestWeight;
                finalColor += desertColor * desertWeight;
                finalColor += mountainColor * mountainWeight;
                finalColor += snowColor * snowWeight;
                finalColor /= totalWeight;

                float detailNoise = FractalNoise(worldUV * max(0.0001, _DetailScale));
                float detail = lerp(1.0 - _DetailStrength, 1.0 + _DetailStrength, detailNoise);
                finalColor *= detail;
                finalColor = lerp(finalColor, fallbackColor, _FallbackColorStrength * saturate(1.0 - waterWeight));

                float3 normalWS = normalize(input.normalWS);
                float fakeLight = saturate(dot(normalWS, normalize(float3(0.35, 0.85, 0.4)))) * 0.5 + 0.5;
                finalColor *= lerp(1.0, fakeLight, _FakeLightStrength);

                return half4(saturate(finalColor), 1);
            }
            ENDHLSL
        }
    }
}
