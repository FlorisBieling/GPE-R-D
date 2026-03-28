// Made with Amplify Shader Editor v1.9.9.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Nicrom/NHP/ASE/Stylised Flower With Stem"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_FlowerColor1( "Flower Color 1", Color ) = ( 0.7843137, 0.454902, 0.1411765, 1 )
		_FlowerColor2( "Flower Color 2", Color ) = ( 0.8980392, 0.9529412, 1, 1 )
		_ColorBlendStart( "Color Blend Start", Range( 0, 1 ) ) = 0.1
		_ColorBlendEnd( "Color Blend End", Range( 0, 1 ) ) = 0.15
		_StemColor( "Stem Color", Color ) = ( 0.3960784, 0.5647059, 0.1019608, 1 )
		[NoScaleOffset] _MainTex( "Flower Texture", 2D ) = "white" {}
		[NoScaleOffset] _StemTexture( "Stem Texture", 2D ) = "white" {}
		_AlphaCutoff( "Alpha Cutoff", Range( 0, 1 ) ) = 0.5
		_MBDefaultBending( "MB Default Bending", Float ) = 0
		_MBAmplitude( "MB Amplitude", Float ) = 1.5
		_MBAmplitudeOffset( "MB Amplitude Offset", Float ) = 2
		_MBFrequency( "MB Frequency", Float ) = 1.11
		_MBFrequencyOffset( "MB Frequency Offset", Float ) = 0
		_MBPhase( "MB Phase", Float ) = 1
		_MBWindDir( "MB Wind Dir", Range( 0, 360 ) ) = 0
		_MBWindDirOffset( "MB Wind Dir Offset", Range( 0, 180 ) ) = 20
		_MBWindDirBlend( "MB Wind Dir Blend", Range( 0, 1 ) ) = 0
		_MBMaxHeight( "MB Max Height", Float ) = 1
		[Toggle( _ENABLEHORIZONTALBENDING_ON )] _EnableHorizontalBending( "Enable Horizontal Bending", Float ) = 1
		_DBHorizontalAmplitude( "DB Horizontal Amplitude", Float ) = 2
		_DBHorizontalFrequency( "DB Horizontal Frequency", Float ) = 1.16
		_DBHorizontalPhase( "DB Horizontal Phase", Float ) = 1
		_DBHorizontalMaxRadius( "DB Horizontal Max Radius", Float ) = 0.05
		[Toggle( _ENABLESLOPECORRECTION_ON )] _EnableSlopeCorrection( "Enable Slope Correction", Float ) = 1
		_SlopeCorrectionMagnitude( "Slope Correction Magnitude", Range( 0, 1 ) ) = 1
		_SlopeCorrectionOffset( "Slope Correction Offset", Range( 0, 1 ) ) = 0
		[NoScaleOffset] _NoiseTexture( "Noise Texture", 2D ) = "white" {}
		_NoiseTextureTilling( "Noise Tilling - Static (XY), Animated (ZW)", Vector ) = ( 1, 1, 1, 1 )
		_NoisePannerSpeed( "Noise Panner Speed", Vector ) = ( 0.05, 0.03, 0, 0 )


		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5

		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		//_InstancedTerrainNormals("Instanced Terrain Normals", Float) = 1.0

		//[ToggleOff(_SPECULARHIGHLIGHTS_OFF)] _SpecularHighlights("Specular Highlights", Float) = 1.0
		//[ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
		//[HideInInspector][ToggleUI] _ReceiveShadows("Receive Shadows", Float) = 1.0

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		//[HideInInspector][ToggleUI] _AddPrecomputedVelocity("Add Precomputed Velocity", Float) = 1

		[HideInInspector] _AlphaClip("__clip", Float) = 0.0
	}

	SubShader
	{
		LOD 0

		

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Lit" }

		Cull Off
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#if ( SHADER_TARGET > 35 ) && defined( SHADER_API_GLES3 )
			#error For WebGL2/GLES3, please set your shader target to 3.5 via SubShader options. URP shaders in ASE use target 4.5 by default.
		#endif

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGB

			

			HLSLPROGRAM

			#define ASE_GEOMETRY
			#define _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define ASE_VERSION 19908
			#define ASE_SRP_VERSION 170004


			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _FORWARD_PLUS

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ USE_LEGACY_LIGHTMAPS

			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_FORWARD

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#if defined( UNITY_INSTANCING_ENABLED ) && defined( ASE_INSTANCED_TERRAIN ) && ( defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL) || defined(_INSTANCEDTERRAINNORMALS_PIXEL) )
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _ENABLESLOPECORRECTION_ON
			#pragma shader_feature_local _ENABLEHORIZONTALBENDING_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					float4 texcoord1 : TEXCOORD1;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					float4 texcoord2 : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				half3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2; // holds terrainUV ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
				float4 lightmapUVOrVertexSH : TEXCOORD3;
				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					half4 fogFactorAndVertexLight : TEXCOORD4;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV : TEXCOORD5;
				#endif
				#if defined(USE_APV_PROBE_OCCLUSION)
					float4 probeOcclusion : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _NoiseTextureTilling;
			float4 _FlowerColor2;
			float4 _FlowerColor1;
			float4 _StemColor;
			float2 _NoisePannerSpeed;
			float _MBWindDir;
			float _ColorBlendEnd;
			float _ColorBlendStart;
			float _SlopeCorrectionMagnitude;
			float _SlopeCorrectionOffset;
			float _DBHorizontalMaxRadius;
			float _DBHorizontalPhase;
			float _DBHorizontalFrequency;
			float _MBMaxHeight;
			float _MBDefaultBending;
			float _MBPhase;
			float _MBFrequencyOffset;
			float _MBFrequency;
			float _MBAmplitudeOffset;
			float _MBAmplitude;
			float _MBWindDirOffset;
			float _MBWindDirBlend;
			float _DBHorizontalAmplitude;
			float _AlphaCutoff;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float MBGlobalWindDir;
			sampler2D _NoiseTexture;
			sampler2D _MainTex;
			sampler2D _StemTexture;


			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float lerpResult181 = lerp( _MBWindDir , MBGlobalWindDir , _MBWindDirBlend);
				float MB_WindDirection205 = lerpResult181;
				float MB_WindDirectionOffset204 = _MBWindDirOffset;
				float2 texCoord152 = input.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult153 = (float3(texCoord152.x , 0.0 , texCoord152.y));
				float3 LocalPivot154 = -appendResult153;
				float3 objToWorld11_g134 = mul( GetObjectToWorldMatrix(), float4( LocalPivot154, 1 ) ).xyz;
				float2 appendResult10_g134 = (float2(objToWorld11_g134.x , objToWorld11_g134.z));
				float2 UVs27_g135 = appendResult10_g134;
				float4 temp_output_24_0_g135 = _NoiseTextureTilling;
				float2 AnimatedNoiseTilling29_g135 = (temp_output_24_0_g135).zw;
				float2 panner7_g135 = ( 0.1 * _Time.y * _NoisePannerSpeed + float2( 0,0 ));
				float4 AnimatedNoise216 = tex2Dlod( _NoiseTexture, float4( ( ( UVs27_g135 * AnimatedNoiseTilling29_g135 ) + panner7_g135 ), 0, 0.0) );
				float temp_output_11_0_g141 = radians( ( ( MB_WindDirection205 + ( MB_WindDirectionOffset204 *  (-1.0 + ( (AnimatedNoise216).x - 0.0 ) * ( 1.0 - -1.0 ) / ( 1.0 - 0.0 ) ) ) ) * -1.0 ) );
				float3 appendResult14_g141 = (float3(cos( temp_output_11_0_g141 ) , 0.0 , sin( temp_output_11_0_g141 )));
				float3 worldToObj35_g141 = mul( GetWorldToObjectMatrix(), float4( appendResult14_g141, 1 ) ).xyz;
				float3 worldToObj36_g141 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult34_g141 = normalize( (( worldToObj35_g141 - worldToObj36_g141 )).xyz );
				float3 MB_RotationAxis246 = normalizeResult34_g141;
				float3 RotationAxis56_g143 = MB_RotationAxis246;
				float MB_Amplitude207 = _MBAmplitude;
				float MB_AmplitudeOffset218 = _MBAmplitudeOffset;
				float2 StaticNoileTilling28_g135 = (temp_output_24_0_g135).xy;
				float4 StaticNoise202 = tex2Dlod( _NoiseTexture, float4( ( UVs27_g135 * StaticNoileTilling28_g135 ), 0, 0.0) );
				float4 StaticWorldNoise31_g142 = StaticNoise202;
				float3 objToWorld52_g142 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float MB_Frequency215 = _MBFrequency;
				float MB_FrequencyOffset209 = _MBFrequencyOffset;
				float DB_PhaseShift194 = input.ase_color.a;
				float MB_Phase208 = _MBPhase;
				float MB_DefaultBending206 = _MBDefaultBending;
				float MB_MaxHeight211 = _MBMaxHeight;
				float MB_RotationAngle245 = radians( ( ( ( ( MB_Amplitude207 + ( MB_AmplitudeOffset218 * (StaticWorldNoise31_g142).x ) ) * sin( ( ( ( objToWorld52_g142.x + objToWorld52_g142.z ) + ( ( ( _TimeParameters.x ) * ( MB_Frequency215 + ( MB_FrequencyOffset209 * (StaticWorldNoise31_g142).x ) ) ) + ( ( 2.0 * PI ) * DB_PhaseShift194 ) ) ) * MB_Phase208 ) ) ) + MB_DefaultBending206 ) * ( input.positionOS.xyz.y / MB_MaxHeight211 ) ) );
				float RotationAngle54_g143 = MB_RotationAngle245;
				float3 PivotPoint60_g143 = LocalPivot154;
				float3 break62_g143 = PivotPoint60_g143;
				float3 appendResult45_g143 = (float3(break62_g143.x , input.positionOS.xyz.y , break62_g143.z));
				float3 rotatedValue30_g143 = RotateAroundAxis( appendResult45_g143, input.positionOS.xyz, RotationAxis56_g143, RotationAngle54_g143 );
				float DB_HorizontalAmplitude189 = _DBHorizontalAmplitude;
				float DB_HorizontalFrequency193 = _DBHorizontalFrequency;
				float Frequency41_g136 = DB_HorizontalFrequency193;
				float3 objToWorld53_g136 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float DB_HorizontalPhase187 = _DBHorizontalPhase;
				float3 PivotPoint49_g136 = LocalPivot154;
				float3 break52_g136 = PivotPoint49_g136;
				float3 appendResult20_g136 = (float3(break52_g136.x , input.positionOS.xyz.y , break52_g136.z));
				float DB_HorizontalMaxRadius192 = _DBHorizontalMaxRadius;
				float3 rotatedValue33_g136 = RotateAroundAxis( PivotPoint49_g136, input.positionOS.xyz, float3( 0, 1, 0 ), radians( ( ( DB_HorizontalAmplitude189 * sin( ( ( ( ( _TimeParameters.x ) * Frequency41_g136 ) - ( ( 2.0 * PI ) * ( 1.0 - DB_PhaseShift194 ) ) ) + ( ( ( objToWorld53_g136.x + objToWorld53_g136.z ) + ( ( _TimeParameters.x ) * Frequency41_g136 ) ) * DB_HorizontalPhase187 ) ) ) ) * ( distance( input.positionOS.xyz , appendResult20_g136 ) / DB_HorizontalMaxRadius192 ) ) ) );
				#ifdef _ENABLEHORIZONTALBENDING_ON
				float3 staticSwitch242 = ( ( rotatedValue33_g136 - input.positionOS.xyz ) * 1.0 );
				#else
				float3 staticSwitch242 = float3( 0, 0, 0 );
				#endif
				float3 DB_VertexOffset248 = staticSwitch242;
				float3 rotatedValue34_g143 = RotateAroundAxis( PivotPoint60_g143, ( rotatedValue30_g143 + DB_VertexOffset248 ), RotationAxis56_g143, RotationAngle54_g143 );
				float3 temp_output_265_0 = ( ( rotatedValue34_g143 - input.positionOS.xyz ) * step( 0.01 , input.positionOS.xyz.y ) );
				float3 MainBending89_g144 = temp_output_265_0;
				float3 appendResult15_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld98_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult15_g144, 1 ) ).xyz;
				float3 objToWorld102_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 break20_g144 = ( objToWorld98_g144 - objToWorld102_g144 );
				float3 appendResult24_g144 = (float3(-break20_g144.z , 0.0 , break20_g144.x));
				float3 appendResult3_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld100_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult3_g144, 1 ) ).xyz;
				float3 objToWorld106_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 temp_output_107_0_g144 = ( objToWorld100_g144 - objToWorld106_g144 );
				float3 break108_g144 = temp_output_107_0_g144;
				float3 lerpResult84_g144 = lerp( float3( 0, 1, 0 ) , temp_output_107_0_g144 , step( 0.001 , ( abs( break108_g144.x ) + abs( break108_g144.z ) ) ));
				float3 normalizeResult7_g144 = normalize( lerpResult84_g144 );
				float dotResult9_g144 = dot( normalizeResult7_g144 , float3( 0, 1, 0 ) );
				float temp_output_12_0_g144 = acos( dotResult9_g144 );
				float NaNPrevention21_g144 = step( 0.01 , abs( ( temp_output_12_0_g144 * ( 180.0 / PI ) ) ) );
				float3 lerpResult26_g144 = lerp( float3( 1, 0, 0 ) , appendResult24_g144 , NaNPrevention21_g144);
				float3 worldToObj99_g144 = mul( GetWorldToObjectMatrix(), float4( lerpResult26_g144, 1 ) ).xyz;
				float3 worldToObj105_g144 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult49_g144 = normalize( ( worldToObj99_g144 - worldToObj105_g144 ) );
				float3 RotationAxis30_g144 = normalizeResult49_g144;
				float SlopeCorrectionOffset269 = _SlopeCorrectionOffset;
				float SlopeCorrectionMagnitude268 = _SlopeCorrectionMagnitude;
				float RotationAngle29_g144 = ( saturate( (  (0.0 + ( (StaticNoise202).x - 0.0 ) * ( SlopeCorrectionOffset269 - 0.0 ) / ( 1.0 - 0.0 ) ) + SlopeCorrectionMagnitude268 ) ) * temp_output_12_0_g144 );
				float3 rotatedValue35_g144 = RotateAroundAxis( LocalPivot154, ( input.positionOS.xyz + MainBending89_g144 ), RotationAxis30_g144, RotationAngle29_g144 );
				float3 lerpResult52_g144 = lerp( MainBending89_g144 , ( rotatedValue35_g144 - input.positionOS.xyz ) , NaNPrevention21_g144);
				#ifdef _ENABLESLOPECORRECTION_ON
				float3 staticSwitch282 = lerpResult52_g144;
				#else
				float3 staticSwitch282 = temp_output_265_0;
				#endif
				float3 LocalVertexOffset285 = staticSwitch282;
				
				output.ase_texcoord7.xy = input.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord7.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = LocalVertexOffset285;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif
				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				OUTPUT_LIGHTMAP_UV(input.texcoord1, unity_LightmapST, output.lightmapUVOrVertexSH.xy);
				#if defined(DYNAMICLIGHTMAP_ON)
					output.dynamicLightmapUV.xy = input.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif
				OUTPUT_SH4(vertexInput.positionWS, normalInput.normalWS.xyz, GetWorldSpaceNormalizeViewDir(vertexInput.positionWS), output.lightmapUVOrVertexSH.xyz, output.probeOcclusion);

				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					output.fogFactorAndVertexLight = 0;
					#if defined(ASE_FOG) && !defined(_FOG_FRAGMENT)
						output.fogFactorAndVertexLight.x = ComputeFogFactor(vertexInput.positionCS.z);
					#endif
					#ifdef _ADDITIONAL_LIGHTS_VERTEX
						half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );
						output.fogFactorAndVertexLight.yzw = vertexLight;
					#endif
				#endif

				output.positionCS = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				output.normalWS = normalInput.normalWS;
				output.tangentWS = float4( normalInput.tangentWS, ( input.tangentOS.w > 0.0 ? 1.0 : -1.0 ) * GetOddNegativeScale() );

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					output.tangentWS.zw = input.texcoord.xy;
					output.tangentWS.xy = input.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					float4 texcoord1 : TEXCOORD1;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					float4 texcoord2 : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.texcoord = input.texcoord;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					output.texcoord1 = input.texcoord1;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					output.texcoord2 = input.texcoord2;
				#endif
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					output.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					output.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				#endif
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag ( PackedVaryings input
						#if defined( ASE_DEPTH_WRITE_ON )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined( _SURFACE_TYPE_TRANSPARENT )
					const bool isTransparent = true;
				#else
					const bool isTransparent = false;
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					float4 shadowCoord = TransformWorldToShadowCoord( input.positionWS );
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				// @diogo: mikktspace compliant
				float renormFactor = 1.0 / max( FLT_MIN, length( input.normalWS ) );

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				float3 ViewDirWS = GetWorldSpaceNormalizeViewDir( PositionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );
				float3 TangentWS = input.tangentWS.xyz * renormFactor;
				float3 BitangentWS = cross( input.normalWS, input.tangentWS.xyz ) * input.tangentWS.w * renormFactor;
				float3 NormalWS = input.normalWS * renormFactor;

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					float2 sampleCoords = (input.tangentWS.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					NormalWS = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					TangentWS = -cross(GetObjectToWorldMatrix()._13_23_33, NormalWS);
					BitangentWS = cross(NormalWS, -TangentWS);
				#endif

				float2 uv_MainTex253 = input.ase_texcoord7.xy;
				float4 tex2DNode253 = tex2D( _MainTex, uv_MainTex253 );
				float2 uv_StemTexture260 = input.ase_texcoord7.xy;
				float4 tex2DNode260 = tex2D( _StemTexture, uv_StemTexture260 );
				float TextureMask250 = step( 1.5 , input.ase_texcoord7.xy.x );
				float4 lerpResult267 = lerp( tex2DNode253 , tex2DNode260 , TextureMask250);
				float4 TextureColor272 = lerpResult267;
				float DistanceToCenter177 = distance( float2( 0.5,0.5 ) , input.ase_texcoord7.xy );
				float ColorBlendStart173 = _ColorBlendStart;
				float ColorBlendEnd190 = _ColorBlendEnd;
				float4 lerpResult255 = lerp( _FlowerColor1 , _FlowerColor2 , ( saturate( ( ( DistanceToCenter177 - ColorBlendStart173 ) / ColorBlendEnd190 ) ) * step( ColorBlendStart173 , DistanceToCenter177 ) ));
				float4 lerpResult264 = lerp( lerpResult255 , _StemColor , TextureMask250);
				float4 Color274 = lerpResult264;
				float4 Albedo284 = ( TextureColor272 * Color274 );
				
				float lerpResult280 = lerp( tex2DNode253.a , tex2DNode260.a , TextureMask250);
				float Opacity283 = lerpResult280;
				

				float3 BaseColor = Albedo284.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Specular = 0.5;
				float Metallic = 0.0;
				float Smoothness = 0.0;
				float Occlusion = 1;
				float3 Emission = 0;
				float Alpha = Opacity283;
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _AlphaCutoff;
					float AlphaClipThresholdShadow = 0.5;
				#endif
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#ifdef _CLEARCOAT
					float CoatMask = 0;
					float CoatSmoothness = 0;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_CHANGES_WORLD_POS)
					ShadowCoord = TransformWorldToShadowCoord( PositionWS );
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = PositionWS;
				inputData.positionCS = input.positionCS;
				inputData.normalizedScreenSpaceUV = ScreenPosNorm.xy;
				inputData.viewDirectionWS = ViewDirWS;
				inputData.shadowCoord = ShadowCoord;

				#ifdef _NORMALMAP
						#if _NORMAL_DROPOFF_TS
							inputData.normalWS = TransformTangentToWorld(Normal, half3x3(TangentWS, BitangentWS, NormalWS));
						#elif _NORMAL_DROPOFF_OS
							inputData.normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							inputData.normalWS = Normal;
						#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = NormalWS;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactorAndVertexLight.x);
				#endif
				#ifdef _ADDITIONAL_LIGHTS_VERTEX
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				#endif

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = input.lightmapUVOrVertexSH.xyz;
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, input.dynamicLightmapUV.xy, SH, inputData.normalWS);
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUVOrVertexSH.xy);
				#elif !defined(LIGHTMAP_ON) && (defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2))
					inputData.bakedGI = SAMPLE_GI( SH, GetAbsolutePositionWS(inputData.positionWS),
						inputData.normalWS,
						inputData.viewDirectionWS,
						input.positionCS.xy,
						input.probeOcclusion,
						inputData.shadowMask );
				#else
					inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUVOrVertexSH.xy);
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
					#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = input.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
					#if defined(USE_APV_PROBE_OCCLUSION)
						inputData.probeOcclusion = input.probeOcclusion;
					#endif
				#endif

				SurfaceData surfaceData;
				surfaceData.albedo              = BaseColor;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness),
				surfaceData.occlusion           = Occlusion,
				surfaceData.emission            = Emission,
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = Normal;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;

				#ifdef _CLEARCOAT
					surfaceData.clearCoatMask       = saturate(CoatMask);
					surfaceData.clearCoatSmoothness = saturate(CoatSmoothness);
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
				#endif

				#ifdef ASE_LIGHTING_SIMPLE
					half4 color = UniversalFragmentBlinnPhong( inputData, surfaceData);
				#else
					half4 color = UniversalFragmentPBR( inputData, surfaceData);
				#endif

				#ifdef ASE_TRANSMISSION
				{
					float shadow = _TransmissionShadow;

					#define SUM_LIGHT_TRANSMISSION(Light)\
						float3 atten = Light.color * Light.distanceAttenuation;\
						atten = lerp( atten, atten * Light.shadowAttenuation, shadow );\
						half3 transmission = max( 0, -dot( inputData.normalWS, Light.direction ) ) * atten * Transmission;\
						color.rgb += BaseColor * transmission;

					SUM_LIGHT_TRANSMISSION( GetMainLight( inputData.shadowCoord ) );

					#if defined(_ADDITIONAL_LIGHTS)
						uint meshRenderingLayers = GetMeshRenderingLayer();
						uint pixelLightCount = GetAdditionalLightsCount();
						#if USE_FORWARD_PLUS
							[loop] for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
							{
								FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

								Light light = GetAdditionalLight(lightIndex, inputData.positionWS, inputData.shadowMask);
								#ifdef _LIGHT_LAYERS
								if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
								#endif
								{
									SUM_LIGHT_TRANSMISSION( light );
								}
							}
						#endif
						LIGHT_LOOP_BEGIN( pixelLightCount )
							Light light = GetAdditionalLight(lightIndex, inputData.positionWS, inputData.shadowMask);
							#ifdef _LIGHT_LAYERS
							if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
							#endif
							{
								SUM_LIGHT_TRANSMISSION( light );
							}
						LIGHT_LOOP_END
					#endif
				}
				#endif

				#ifdef ASE_TRANSLUCENCY
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					#define SUM_LIGHT_TRANSLUCENCY(Light)\
						float3 atten = Light.color * Light.distanceAttenuation;\
						atten = lerp( atten, atten * Light.shadowAttenuation, shadow );\
						half3 lightDir = Light.direction + inputData.normalWS * normal;\
						half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );\
						half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;\
						color.rgb += BaseColor * translucency * strength;

					SUM_LIGHT_TRANSLUCENCY( GetMainLight( inputData.shadowCoord ) );

					#if defined(_ADDITIONAL_LIGHTS)
						uint meshRenderingLayers = GetMeshRenderingLayer();
						uint pixelLightCount = GetAdditionalLightsCount();
						#if USE_FORWARD_PLUS
							[loop] for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
							{
								FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

								Light light = GetAdditionalLight(lightIndex, inputData.positionWS, inputData.shadowMask);
								#ifdef _LIGHT_LAYERS
								if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
								#endif
								{
									SUM_LIGHT_TRANSLUCENCY( light );
								}
							}
						#endif
						LIGHT_LOOP_BEGIN( pixelLightCount )
							Light light = GetAdditionalLight(lightIndex, inputData.positionWS, inputData.shadowMask);
							#ifdef _LIGHT_LAYERS
							if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
							#endif
							{
								SUM_LIGHT_TRANSLUCENCY( light );
							}
						LIGHT_LOOP_END
					#endif
				}
				#endif

				#ifdef ASE_REFRACTION
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( NormalWS,0 ) ).xyz * ( 1.0 - dot( NormalWS, ViewDirWS ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3(0,0,0), inputData.fogCoord);
					#else
						color.rgb = MixFog(color.rgb, inputData.fogCoord);
					#endif
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				#if defined( ASE_OPAQUE_KEEP_ALPHA )
					return half4( color.rgb, color.a );
				#else
					return half4( color.rgb, OutputAlpha( color.a, isTransparent ) );
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#define ASE_GEOMETRY
			#define _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define ASE_VERSION 19908
			#define ASE_SRP_VERSION 170004


			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _ENABLESLOPECORRECTION_ON
			#pragma shader_feature_local _ENABLEHORIZONTALBENDING_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _NoiseTextureTilling;
			float4 _FlowerColor2;
			float4 _FlowerColor1;
			float4 _StemColor;
			float2 _NoisePannerSpeed;
			float _MBWindDir;
			float _ColorBlendEnd;
			float _ColorBlendStart;
			float _SlopeCorrectionMagnitude;
			float _SlopeCorrectionOffset;
			float _DBHorizontalMaxRadius;
			float _DBHorizontalPhase;
			float _DBHorizontalFrequency;
			float _MBMaxHeight;
			float _MBDefaultBending;
			float _MBPhase;
			float _MBFrequencyOffset;
			float _MBFrequency;
			float _MBAmplitudeOffset;
			float _MBAmplitude;
			float _MBWindDirOffset;
			float _MBWindDirBlend;
			float _DBHorizontalAmplitude;
			float _AlphaCutoff;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float MBGlobalWindDir;
			sampler2D _NoiseTexture;
			sampler2D _MainTex;
			sampler2D _StemTexture;


			float3 _LightDirection;
			float3 _LightPosition;

			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			PackedVaryings VertexFunction( Attributes input )
			{
				PackedVaryings output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output );

				float lerpResult181 = lerp( _MBWindDir , MBGlobalWindDir , _MBWindDirBlend);
				float MB_WindDirection205 = lerpResult181;
				float MB_WindDirectionOffset204 = _MBWindDirOffset;
				float2 texCoord152 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult153 = (float3(texCoord152.x , 0.0 , texCoord152.y));
				float3 LocalPivot154 = -appendResult153;
				float3 objToWorld11_g134 = mul( GetObjectToWorldMatrix(), float4( LocalPivot154, 1 ) ).xyz;
				float2 appendResult10_g134 = (float2(objToWorld11_g134.x , objToWorld11_g134.z));
				float2 UVs27_g135 = appendResult10_g134;
				float4 temp_output_24_0_g135 = _NoiseTextureTilling;
				float2 AnimatedNoiseTilling29_g135 = (temp_output_24_0_g135).zw;
				float2 panner7_g135 = ( 0.1 * _Time.y * _NoisePannerSpeed + float2( 0,0 ));
				float4 AnimatedNoise216 = tex2Dlod( _NoiseTexture, float4( ( ( UVs27_g135 * AnimatedNoiseTilling29_g135 ) + panner7_g135 ), 0, 0.0) );
				float temp_output_11_0_g141 = radians( ( ( MB_WindDirection205 + ( MB_WindDirectionOffset204 *  (-1.0 + ( (AnimatedNoise216).x - 0.0 ) * ( 1.0 - -1.0 ) / ( 1.0 - 0.0 ) ) ) ) * -1.0 ) );
				float3 appendResult14_g141 = (float3(cos( temp_output_11_0_g141 ) , 0.0 , sin( temp_output_11_0_g141 )));
				float3 worldToObj35_g141 = mul( GetWorldToObjectMatrix(), float4( appendResult14_g141, 1 ) ).xyz;
				float3 worldToObj36_g141 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult34_g141 = normalize( (( worldToObj35_g141 - worldToObj36_g141 )).xyz );
				float3 MB_RotationAxis246 = normalizeResult34_g141;
				float3 RotationAxis56_g143 = MB_RotationAxis246;
				float MB_Amplitude207 = _MBAmplitude;
				float MB_AmplitudeOffset218 = _MBAmplitudeOffset;
				float2 StaticNoileTilling28_g135 = (temp_output_24_0_g135).xy;
				float4 StaticNoise202 = tex2Dlod( _NoiseTexture, float4( ( UVs27_g135 * StaticNoileTilling28_g135 ), 0, 0.0) );
				float4 StaticWorldNoise31_g142 = StaticNoise202;
				float3 objToWorld52_g142 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float MB_Frequency215 = _MBFrequency;
				float MB_FrequencyOffset209 = _MBFrequencyOffset;
				float DB_PhaseShift194 = input.ase_color.a;
				float MB_Phase208 = _MBPhase;
				float MB_DefaultBending206 = _MBDefaultBending;
				float MB_MaxHeight211 = _MBMaxHeight;
				float MB_RotationAngle245 = radians( ( ( ( ( MB_Amplitude207 + ( MB_AmplitudeOffset218 * (StaticWorldNoise31_g142).x ) ) * sin( ( ( ( objToWorld52_g142.x + objToWorld52_g142.z ) + ( ( ( _TimeParameters.x ) * ( MB_Frequency215 + ( MB_FrequencyOffset209 * (StaticWorldNoise31_g142).x ) ) ) + ( ( 2.0 * PI ) * DB_PhaseShift194 ) ) ) * MB_Phase208 ) ) ) + MB_DefaultBending206 ) * ( input.positionOS.xyz.y / MB_MaxHeight211 ) ) );
				float RotationAngle54_g143 = MB_RotationAngle245;
				float3 PivotPoint60_g143 = LocalPivot154;
				float3 break62_g143 = PivotPoint60_g143;
				float3 appendResult45_g143 = (float3(break62_g143.x , input.positionOS.xyz.y , break62_g143.z));
				float3 rotatedValue30_g143 = RotateAroundAxis( appendResult45_g143, input.positionOS.xyz, RotationAxis56_g143, RotationAngle54_g143 );
				float DB_HorizontalAmplitude189 = _DBHorizontalAmplitude;
				float DB_HorizontalFrequency193 = _DBHorizontalFrequency;
				float Frequency41_g136 = DB_HorizontalFrequency193;
				float3 objToWorld53_g136 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float DB_HorizontalPhase187 = _DBHorizontalPhase;
				float3 PivotPoint49_g136 = LocalPivot154;
				float3 break52_g136 = PivotPoint49_g136;
				float3 appendResult20_g136 = (float3(break52_g136.x , input.positionOS.xyz.y , break52_g136.z));
				float DB_HorizontalMaxRadius192 = _DBHorizontalMaxRadius;
				float3 rotatedValue33_g136 = RotateAroundAxis( PivotPoint49_g136, input.positionOS.xyz, float3( 0, 1, 0 ), radians( ( ( DB_HorizontalAmplitude189 * sin( ( ( ( ( _TimeParameters.x ) * Frequency41_g136 ) - ( ( 2.0 * PI ) * ( 1.0 - DB_PhaseShift194 ) ) ) + ( ( ( objToWorld53_g136.x + objToWorld53_g136.z ) + ( ( _TimeParameters.x ) * Frequency41_g136 ) ) * DB_HorizontalPhase187 ) ) ) ) * ( distance( input.positionOS.xyz , appendResult20_g136 ) / DB_HorizontalMaxRadius192 ) ) ) );
				#ifdef _ENABLEHORIZONTALBENDING_ON
				float3 staticSwitch242 = ( ( rotatedValue33_g136 - input.positionOS.xyz ) * 1.0 );
				#else
				float3 staticSwitch242 = float3( 0, 0, 0 );
				#endif
				float3 DB_VertexOffset248 = staticSwitch242;
				float3 rotatedValue34_g143 = RotateAroundAxis( PivotPoint60_g143, ( rotatedValue30_g143 + DB_VertexOffset248 ), RotationAxis56_g143, RotationAngle54_g143 );
				float3 temp_output_265_0 = ( ( rotatedValue34_g143 - input.positionOS.xyz ) * step( 0.01 , input.positionOS.xyz.y ) );
				float3 MainBending89_g144 = temp_output_265_0;
				float3 appendResult15_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld98_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult15_g144, 1 ) ).xyz;
				float3 objToWorld102_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 break20_g144 = ( objToWorld98_g144 - objToWorld102_g144 );
				float3 appendResult24_g144 = (float3(-break20_g144.z , 0.0 , break20_g144.x));
				float3 appendResult3_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld100_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult3_g144, 1 ) ).xyz;
				float3 objToWorld106_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 temp_output_107_0_g144 = ( objToWorld100_g144 - objToWorld106_g144 );
				float3 break108_g144 = temp_output_107_0_g144;
				float3 lerpResult84_g144 = lerp( float3( 0, 1, 0 ) , temp_output_107_0_g144 , step( 0.001 , ( abs( break108_g144.x ) + abs( break108_g144.z ) ) ));
				float3 normalizeResult7_g144 = normalize( lerpResult84_g144 );
				float dotResult9_g144 = dot( normalizeResult7_g144 , float3( 0, 1, 0 ) );
				float temp_output_12_0_g144 = acos( dotResult9_g144 );
				float NaNPrevention21_g144 = step( 0.01 , abs( ( temp_output_12_0_g144 * ( 180.0 / PI ) ) ) );
				float3 lerpResult26_g144 = lerp( float3( 1, 0, 0 ) , appendResult24_g144 , NaNPrevention21_g144);
				float3 worldToObj99_g144 = mul( GetWorldToObjectMatrix(), float4( lerpResult26_g144, 1 ) ).xyz;
				float3 worldToObj105_g144 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult49_g144 = normalize( ( worldToObj99_g144 - worldToObj105_g144 ) );
				float3 RotationAxis30_g144 = normalizeResult49_g144;
				float SlopeCorrectionOffset269 = _SlopeCorrectionOffset;
				float SlopeCorrectionMagnitude268 = _SlopeCorrectionMagnitude;
				float RotationAngle29_g144 = ( saturate( (  (0.0 + ( (StaticNoise202).x - 0.0 ) * ( SlopeCorrectionOffset269 - 0.0 ) / ( 1.0 - 0.0 ) ) + SlopeCorrectionMagnitude268 ) ) * temp_output_12_0_g144 );
				float3 rotatedValue35_g144 = RotateAroundAxis( LocalPivot154, ( input.positionOS.xyz + MainBending89_g144 ), RotationAxis30_g144, RotationAngle29_g144 );
				float3 lerpResult52_g144 = lerp( MainBending89_g144 , ( rotatedValue35_g144 - input.positionOS.xyz ) , NaNPrevention21_g144);
				#ifdef _ENABLESLOPECORRECTION_ON
				float3 staticSwitch282 = lerpResult52_g144;
				#else
				float3 staticSwitch282 = temp_output_265_0;
				#endif
				float3 LocalVertexOffset285 = staticSwitch282;
				
				output.ase_texcoord1.xy = input.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord1.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = LocalVertexOffset285;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				float3 positionWS = TransformObjectToWorld( input.positionOS.xyz );
				float3 normalWS = TransformObjectToWorldDir(input.normalOS);

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				//code for UNITY_REVERSED_Z is moved into Shadows.hlsl from 6000.0.22 and or higher
				positionCS = ApplyShadowClamping(positionCS);

				output.positionCS = positionCS;
				output.positionWS = positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				output.ase_texcoord = input.ase_texcoord;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(	PackedVaryings input
						#if defined( ASE_DEPTH_WRITE_ON )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( input.positionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );

				float2 uv_MainTex253 = input.ase_texcoord1.xy;
				float4 tex2DNode253 = tex2D( _MainTex, uv_MainTex253 );
				float2 uv_StemTexture260 = input.ase_texcoord1.xy;
				float4 tex2DNode260 = tex2D( _StemTexture, uv_StemTexture260 );
				float TextureMask250 = step( 1.5 , input.ase_texcoord1.xy.x );
				float lerpResult280 = lerp( tex2DNode253.a , tex2DNode260.a , TextureMask250);
				float Opacity283 = lerpResult280;
				

				float Alpha = Opacity283;
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _AlphaCutoff;
					float AlphaClipThresholdShadow = 0.5;
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					#if defined( _ALPHATEST_SHADOW_ON )
						AlphaDiscard( Alpha, AlphaClipThresholdShadow );
					#else
						AlphaDiscard( Alpha, AlphaClipThreshold );
					#endif
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			#define ASE_GEOMETRY
			#define _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define ASE_VERSION 19908
			#define ASE_SRP_VERSION 170004


			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _ENABLESLOPECORRECTION_ON
			#pragma shader_feature_local _ENABLEHORIZONTALBENDING_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _NoiseTextureTilling;
			float4 _FlowerColor2;
			float4 _FlowerColor1;
			float4 _StemColor;
			float2 _NoisePannerSpeed;
			float _MBWindDir;
			float _ColorBlendEnd;
			float _ColorBlendStart;
			float _SlopeCorrectionMagnitude;
			float _SlopeCorrectionOffset;
			float _DBHorizontalMaxRadius;
			float _DBHorizontalPhase;
			float _DBHorizontalFrequency;
			float _MBMaxHeight;
			float _MBDefaultBending;
			float _MBPhase;
			float _MBFrequencyOffset;
			float _MBFrequency;
			float _MBAmplitudeOffset;
			float _MBAmplitude;
			float _MBWindDirOffset;
			float _MBWindDirBlend;
			float _DBHorizontalAmplitude;
			float _AlphaCutoff;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float MBGlobalWindDir;
			sampler2D _NoiseTexture;
			sampler2D _MainTex;
			sampler2D _StemTexture;


			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float lerpResult181 = lerp( _MBWindDir , MBGlobalWindDir , _MBWindDirBlend);
				float MB_WindDirection205 = lerpResult181;
				float MB_WindDirectionOffset204 = _MBWindDirOffset;
				float2 texCoord152 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult153 = (float3(texCoord152.x , 0.0 , texCoord152.y));
				float3 LocalPivot154 = -appendResult153;
				float3 objToWorld11_g134 = mul( GetObjectToWorldMatrix(), float4( LocalPivot154, 1 ) ).xyz;
				float2 appendResult10_g134 = (float2(objToWorld11_g134.x , objToWorld11_g134.z));
				float2 UVs27_g135 = appendResult10_g134;
				float4 temp_output_24_0_g135 = _NoiseTextureTilling;
				float2 AnimatedNoiseTilling29_g135 = (temp_output_24_0_g135).zw;
				float2 panner7_g135 = ( 0.1 * _Time.y * _NoisePannerSpeed + float2( 0,0 ));
				float4 AnimatedNoise216 = tex2Dlod( _NoiseTexture, float4( ( ( UVs27_g135 * AnimatedNoiseTilling29_g135 ) + panner7_g135 ), 0, 0.0) );
				float temp_output_11_0_g141 = radians( ( ( MB_WindDirection205 + ( MB_WindDirectionOffset204 *  (-1.0 + ( (AnimatedNoise216).x - 0.0 ) * ( 1.0 - -1.0 ) / ( 1.0 - 0.0 ) ) ) ) * -1.0 ) );
				float3 appendResult14_g141 = (float3(cos( temp_output_11_0_g141 ) , 0.0 , sin( temp_output_11_0_g141 )));
				float3 worldToObj35_g141 = mul( GetWorldToObjectMatrix(), float4( appendResult14_g141, 1 ) ).xyz;
				float3 worldToObj36_g141 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult34_g141 = normalize( (( worldToObj35_g141 - worldToObj36_g141 )).xyz );
				float3 MB_RotationAxis246 = normalizeResult34_g141;
				float3 RotationAxis56_g143 = MB_RotationAxis246;
				float MB_Amplitude207 = _MBAmplitude;
				float MB_AmplitudeOffset218 = _MBAmplitudeOffset;
				float2 StaticNoileTilling28_g135 = (temp_output_24_0_g135).xy;
				float4 StaticNoise202 = tex2Dlod( _NoiseTexture, float4( ( UVs27_g135 * StaticNoileTilling28_g135 ), 0, 0.0) );
				float4 StaticWorldNoise31_g142 = StaticNoise202;
				float3 objToWorld52_g142 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float MB_Frequency215 = _MBFrequency;
				float MB_FrequencyOffset209 = _MBFrequencyOffset;
				float DB_PhaseShift194 = input.ase_color.a;
				float MB_Phase208 = _MBPhase;
				float MB_DefaultBending206 = _MBDefaultBending;
				float MB_MaxHeight211 = _MBMaxHeight;
				float MB_RotationAngle245 = radians( ( ( ( ( MB_Amplitude207 + ( MB_AmplitudeOffset218 * (StaticWorldNoise31_g142).x ) ) * sin( ( ( ( objToWorld52_g142.x + objToWorld52_g142.z ) + ( ( ( _TimeParameters.x ) * ( MB_Frequency215 + ( MB_FrequencyOffset209 * (StaticWorldNoise31_g142).x ) ) ) + ( ( 2.0 * PI ) * DB_PhaseShift194 ) ) ) * MB_Phase208 ) ) ) + MB_DefaultBending206 ) * ( input.positionOS.xyz.y / MB_MaxHeight211 ) ) );
				float RotationAngle54_g143 = MB_RotationAngle245;
				float3 PivotPoint60_g143 = LocalPivot154;
				float3 break62_g143 = PivotPoint60_g143;
				float3 appendResult45_g143 = (float3(break62_g143.x , input.positionOS.xyz.y , break62_g143.z));
				float3 rotatedValue30_g143 = RotateAroundAxis( appendResult45_g143, input.positionOS.xyz, RotationAxis56_g143, RotationAngle54_g143 );
				float DB_HorizontalAmplitude189 = _DBHorizontalAmplitude;
				float DB_HorizontalFrequency193 = _DBHorizontalFrequency;
				float Frequency41_g136 = DB_HorizontalFrequency193;
				float3 objToWorld53_g136 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float DB_HorizontalPhase187 = _DBHorizontalPhase;
				float3 PivotPoint49_g136 = LocalPivot154;
				float3 break52_g136 = PivotPoint49_g136;
				float3 appendResult20_g136 = (float3(break52_g136.x , input.positionOS.xyz.y , break52_g136.z));
				float DB_HorizontalMaxRadius192 = _DBHorizontalMaxRadius;
				float3 rotatedValue33_g136 = RotateAroundAxis( PivotPoint49_g136, input.positionOS.xyz, float3( 0, 1, 0 ), radians( ( ( DB_HorizontalAmplitude189 * sin( ( ( ( ( _TimeParameters.x ) * Frequency41_g136 ) - ( ( 2.0 * PI ) * ( 1.0 - DB_PhaseShift194 ) ) ) + ( ( ( objToWorld53_g136.x + objToWorld53_g136.z ) + ( ( _TimeParameters.x ) * Frequency41_g136 ) ) * DB_HorizontalPhase187 ) ) ) ) * ( distance( input.positionOS.xyz , appendResult20_g136 ) / DB_HorizontalMaxRadius192 ) ) ) );
				#ifdef _ENABLEHORIZONTALBENDING_ON
				float3 staticSwitch242 = ( ( rotatedValue33_g136 - input.positionOS.xyz ) * 1.0 );
				#else
				float3 staticSwitch242 = float3( 0, 0, 0 );
				#endif
				float3 DB_VertexOffset248 = staticSwitch242;
				float3 rotatedValue34_g143 = RotateAroundAxis( PivotPoint60_g143, ( rotatedValue30_g143 + DB_VertexOffset248 ), RotationAxis56_g143, RotationAngle54_g143 );
				float3 temp_output_265_0 = ( ( rotatedValue34_g143 - input.positionOS.xyz ) * step( 0.01 , input.positionOS.xyz.y ) );
				float3 MainBending89_g144 = temp_output_265_0;
				float3 appendResult15_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld98_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult15_g144, 1 ) ).xyz;
				float3 objToWorld102_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 break20_g144 = ( objToWorld98_g144 - objToWorld102_g144 );
				float3 appendResult24_g144 = (float3(-break20_g144.z , 0.0 , break20_g144.x));
				float3 appendResult3_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld100_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult3_g144, 1 ) ).xyz;
				float3 objToWorld106_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 temp_output_107_0_g144 = ( objToWorld100_g144 - objToWorld106_g144 );
				float3 break108_g144 = temp_output_107_0_g144;
				float3 lerpResult84_g144 = lerp( float3( 0, 1, 0 ) , temp_output_107_0_g144 , step( 0.001 , ( abs( break108_g144.x ) + abs( break108_g144.z ) ) ));
				float3 normalizeResult7_g144 = normalize( lerpResult84_g144 );
				float dotResult9_g144 = dot( normalizeResult7_g144 , float3( 0, 1, 0 ) );
				float temp_output_12_0_g144 = acos( dotResult9_g144 );
				float NaNPrevention21_g144 = step( 0.01 , abs( ( temp_output_12_0_g144 * ( 180.0 / PI ) ) ) );
				float3 lerpResult26_g144 = lerp( float3( 1, 0, 0 ) , appendResult24_g144 , NaNPrevention21_g144);
				float3 worldToObj99_g144 = mul( GetWorldToObjectMatrix(), float4( lerpResult26_g144, 1 ) ).xyz;
				float3 worldToObj105_g144 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult49_g144 = normalize( ( worldToObj99_g144 - worldToObj105_g144 ) );
				float3 RotationAxis30_g144 = normalizeResult49_g144;
				float SlopeCorrectionOffset269 = _SlopeCorrectionOffset;
				float SlopeCorrectionMagnitude268 = _SlopeCorrectionMagnitude;
				float RotationAngle29_g144 = ( saturate( (  (0.0 + ( (StaticNoise202).x - 0.0 ) * ( SlopeCorrectionOffset269 - 0.0 ) / ( 1.0 - 0.0 ) ) + SlopeCorrectionMagnitude268 ) ) * temp_output_12_0_g144 );
				float3 rotatedValue35_g144 = RotateAroundAxis( LocalPivot154, ( input.positionOS.xyz + MainBending89_g144 ), RotationAxis30_g144, RotationAngle29_g144 );
				float3 lerpResult52_g144 = lerp( MainBending89_g144 , ( rotatedValue35_g144 - input.positionOS.xyz ) , NaNPrevention21_g144);
				#ifdef _ENABLESLOPECORRECTION_ON
				float3 staticSwitch282 = lerpResult52_g144;
				#else
				float3 staticSwitch282 = temp_output_265_0;
				#endif
				float3 LocalVertexOffset285 = staticSwitch282;
				
				output.ase_texcoord1.xy = input.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord1.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = LocalVertexOffset285;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				output.ase_texcoord = input.ase_texcoord;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(	PackedVaryings input
						#if defined( ASE_DEPTH_WRITE_ON )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( input.positionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );

				float2 uv_MainTex253 = input.ase_texcoord1.xy;
				float4 tex2DNode253 = tex2D( _MainTex, uv_MainTex253 );
				float2 uv_StemTexture260 = input.ase_texcoord1.xy;
				float4 tex2DNode260 = tex2D( _StemTexture, uv_StemTexture260 );
				float TextureMask250 = step( 1.5 , input.ase_texcoord1.xy.x );
				float lerpResult280 = lerp( tex2DNode253.a , tex2DNode260.a , TextureMask250);
				float Opacity283 = lerpResult280;
				

				float Alpha = Opacity283;
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _AlphaCutoff;
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			#define ASE_GEOMETRY
			#define _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define ASE_VERSION 19908
			#define ASE_SRP_VERSION 170004

			#pragma shader_feature EDITOR_VISUALIZATION

			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _ENABLESLOPECORRECTION_ON
			#pragma shader_feature_local _ENABLEHORIZONTALBENDING_ON


			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				#ifdef EDITOR_VISUALIZATION
					float4 VizUV : TEXCOORD1;
					float4 LightCoord : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _NoiseTextureTilling;
			float4 _FlowerColor2;
			float4 _FlowerColor1;
			float4 _StemColor;
			float2 _NoisePannerSpeed;
			float _MBWindDir;
			float _ColorBlendEnd;
			float _ColorBlendStart;
			float _SlopeCorrectionMagnitude;
			float _SlopeCorrectionOffset;
			float _DBHorizontalMaxRadius;
			float _DBHorizontalPhase;
			float _DBHorizontalFrequency;
			float _MBMaxHeight;
			float _MBDefaultBending;
			float _MBPhase;
			float _MBFrequencyOffset;
			float _MBFrequency;
			float _MBAmplitudeOffset;
			float _MBAmplitude;
			float _MBWindDirOffset;
			float _MBWindDirBlend;
			float _DBHorizontalAmplitude;
			float _AlphaCutoff;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float MBGlobalWindDir;
			sampler2D _NoiseTexture;
			sampler2D _MainTex;
			sampler2D _StemTexture;


			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float lerpResult181 = lerp( _MBWindDir , MBGlobalWindDir , _MBWindDirBlend);
				float MB_WindDirection205 = lerpResult181;
				float MB_WindDirectionOffset204 = _MBWindDirOffset;
				float2 texCoord152 = input.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult153 = (float3(texCoord152.x , 0.0 , texCoord152.y));
				float3 LocalPivot154 = -appendResult153;
				float3 objToWorld11_g134 = mul( GetObjectToWorldMatrix(), float4( LocalPivot154, 1 ) ).xyz;
				float2 appendResult10_g134 = (float2(objToWorld11_g134.x , objToWorld11_g134.z));
				float2 UVs27_g135 = appendResult10_g134;
				float4 temp_output_24_0_g135 = _NoiseTextureTilling;
				float2 AnimatedNoiseTilling29_g135 = (temp_output_24_0_g135).zw;
				float2 panner7_g135 = ( 0.1 * _Time.y * _NoisePannerSpeed + float2( 0,0 ));
				float4 AnimatedNoise216 = tex2Dlod( _NoiseTexture, float4( ( ( UVs27_g135 * AnimatedNoiseTilling29_g135 ) + panner7_g135 ), 0, 0.0) );
				float temp_output_11_0_g141 = radians( ( ( MB_WindDirection205 + ( MB_WindDirectionOffset204 *  (-1.0 + ( (AnimatedNoise216).x - 0.0 ) * ( 1.0 - -1.0 ) / ( 1.0 - 0.0 ) ) ) ) * -1.0 ) );
				float3 appendResult14_g141 = (float3(cos( temp_output_11_0_g141 ) , 0.0 , sin( temp_output_11_0_g141 )));
				float3 worldToObj35_g141 = mul( GetWorldToObjectMatrix(), float4( appendResult14_g141, 1 ) ).xyz;
				float3 worldToObj36_g141 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult34_g141 = normalize( (( worldToObj35_g141 - worldToObj36_g141 )).xyz );
				float3 MB_RotationAxis246 = normalizeResult34_g141;
				float3 RotationAxis56_g143 = MB_RotationAxis246;
				float MB_Amplitude207 = _MBAmplitude;
				float MB_AmplitudeOffset218 = _MBAmplitudeOffset;
				float2 StaticNoileTilling28_g135 = (temp_output_24_0_g135).xy;
				float4 StaticNoise202 = tex2Dlod( _NoiseTexture, float4( ( UVs27_g135 * StaticNoileTilling28_g135 ), 0, 0.0) );
				float4 StaticWorldNoise31_g142 = StaticNoise202;
				float3 objToWorld52_g142 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float MB_Frequency215 = _MBFrequency;
				float MB_FrequencyOffset209 = _MBFrequencyOffset;
				float DB_PhaseShift194 = input.ase_color.a;
				float MB_Phase208 = _MBPhase;
				float MB_DefaultBending206 = _MBDefaultBending;
				float MB_MaxHeight211 = _MBMaxHeight;
				float MB_RotationAngle245 = radians( ( ( ( ( MB_Amplitude207 + ( MB_AmplitudeOffset218 * (StaticWorldNoise31_g142).x ) ) * sin( ( ( ( objToWorld52_g142.x + objToWorld52_g142.z ) + ( ( ( _TimeParameters.x ) * ( MB_Frequency215 + ( MB_FrequencyOffset209 * (StaticWorldNoise31_g142).x ) ) ) + ( ( 2.0 * PI ) * DB_PhaseShift194 ) ) ) * MB_Phase208 ) ) ) + MB_DefaultBending206 ) * ( input.positionOS.xyz.y / MB_MaxHeight211 ) ) );
				float RotationAngle54_g143 = MB_RotationAngle245;
				float3 PivotPoint60_g143 = LocalPivot154;
				float3 break62_g143 = PivotPoint60_g143;
				float3 appendResult45_g143 = (float3(break62_g143.x , input.positionOS.xyz.y , break62_g143.z));
				float3 rotatedValue30_g143 = RotateAroundAxis( appendResult45_g143, input.positionOS.xyz, RotationAxis56_g143, RotationAngle54_g143 );
				float DB_HorizontalAmplitude189 = _DBHorizontalAmplitude;
				float DB_HorizontalFrequency193 = _DBHorizontalFrequency;
				float Frequency41_g136 = DB_HorizontalFrequency193;
				float3 objToWorld53_g136 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float DB_HorizontalPhase187 = _DBHorizontalPhase;
				float3 PivotPoint49_g136 = LocalPivot154;
				float3 break52_g136 = PivotPoint49_g136;
				float3 appendResult20_g136 = (float3(break52_g136.x , input.positionOS.xyz.y , break52_g136.z));
				float DB_HorizontalMaxRadius192 = _DBHorizontalMaxRadius;
				float3 rotatedValue33_g136 = RotateAroundAxis( PivotPoint49_g136, input.positionOS.xyz, float3( 0, 1, 0 ), radians( ( ( DB_HorizontalAmplitude189 * sin( ( ( ( ( _TimeParameters.x ) * Frequency41_g136 ) - ( ( 2.0 * PI ) * ( 1.0 - DB_PhaseShift194 ) ) ) + ( ( ( objToWorld53_g136.x + objToWorld53_g136.z ) + ( ( _TimeParameters.x ) * Frequency41_g136 ) ) * DB_HorizontalPhase187 ) ) ) ) * ( distance( input.positionOS.xyz , appendResult20_g136 ) / DB_HorizontalMaxRadius192 ) ) ) );
				#ifdef _ENABLEHORIZONTALBENDING_ON
				float3 staticSwitch242 = ( ( rotatedValue33_g136 - input.positionOS.xyz ) * 1.0 );
				#else
				float3 staticSwitch242 = float3( 0, 0, 0 );
				#endif
				float3 DB_VertexOffset248 = staticSwitch242;
				float3 rotatedValue34_g143 = RotateAroundAxis( PivotPoint60_g143, ( rotatedValue30_g143 + DB_VertexOffset248 ), RotationAxis56_g143, RotationAngle54_g143 );
				float3 temp_output_265_0 = ( ( rotatedValue34_g143 - input.positionOS.xyz ) * step( 0.01 , input.positionOS.xyz.y ) );
				float3 MainBending89_g144 = temp_output_265_0;
				float3 appendResult15_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld98_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult15_g144, 1 ) ).xyz;
				float3 objToWorld102_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 break20_g144 = ( objToWorld98_g144 - objToWorld102_g144 );
				float3 appendResult24_g144 = (float3(-break20_g144.z , 0.0 , break20_g144.x));
				float3 appendResult3_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld100_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult3_g144, 1 ) ).xyz;
				float3 objToWorld106_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 temp_output_107_0_g144 = ( objToWorld100_g144 - objToWorld106_g144 );
				float3 break108_g144 = temp_output_107_0_g144;
				float3 lerpResult84_g144 = lerp( float3( 0, 1, 0 ) , temp_output_107_0_g144 , step( 0.001 , ( abs( break108_g144.x ) + abs( break108_g144.z ) ) ));
				float3 normalizeResult7_g144 = normalize( lerpResult84_g144 );
				float dotResult9_g144 = dot( normalizeResult7_g144 , float3( 0, 1, 0 ) );
				float temp_output_12_0_g144 = acos( dotResult9_g144 );
				float NaNPrevention21_g144 = step( 0.01 , abs( ( temp_output_12_0_g144 * ( 180.0 / PI ) ) ) );
				float3 lerpResult26_g144 = lerp( float3( 1, 0, 0 ) , appendResult24_g144 , NaNPrevention21_g144);
				float3 worldToObj99_g144 = mul( GetWorldToObjectMatrix(), float4( lerpResult26_g144, 1 ) ).xyz;
				float3 worldToObj105_g144 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult49_g144 = normalize( ( worldToObj99_g144 - worldToObj105_g144 ) );
				float3 RotationAxis30_g144 = normalizeResult49_g144;
				float SlopeCorrectionOffset269 = _SlopeCorrectionOffset;
				float SlopeCorrectionMagnitude268 = _SlopeCorrectionMagnitude;
				float RotationAngle29_g144 = ( saturate( (  (0.0 + ( (StaticNoise202).x - 0.0 ) * ( SlopeCorrectionOffset269 - 0.0 ) / ( 1.0 - 0.0 ) ) + SlopeCorrectionMagnitude268 ) ) * temp_output_12_0_g144 );
				float3 rotatedValue35_g144 = RotateAroundAxis( LocalPivot154, ( input.positionOS.xyz + MainBending89_g144 ), RotationAxis30_g144, RotationAngle29_g144 );
				float3 lerpResult52_g144 = lerp( MainBending89_g144 , ( rotatedValue35_g144 - input.positionOS.xyz ) , NaNPrevention21_g144);
				#ifdef _ENABLESLOPECORRECTION_ON
				float3 staticSwitch282 = lerpResult52_g144;
				#else
				float3 staticSwitch282 = temp_output_265_0;
				#endif
				float3 LocalVertexOffset285 = staticSwitch282;
				
				output.ase_texcoord3.xy = input.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = LocalVertexOffset285;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				#ifdef EDITOR_VISUALIZATION
					float2 VizUV = 0;
					float4 LightCoord = 0;
					UnityEditorVizData(input.positionOS.xyz, input.texcoord.xy, input.texcoord1.xy, input.texcoord2.xy, VizUV, LightCoord);
					output.VizUV = float4(VizUV, 0, 0);
					output.LightCoord = LightCoord;
				#endif

				output.positionCS = MetaVertexPosition( input.positionOS, input.texcoord1.xy, input.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				output.positionWS = TransformObjectToWorld( input.positionOS.xyz );
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.texcoord = input.texcoord;
				output.texcoord1 = input.texcoord1;
				output.texcoord2 = input.texcoord2;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				output.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				output.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( input.positionWS );
				float4 ShadowCoord = shadowCoord;

				float2 uv_MainTex253 = input.ase_texcoord3.xy;
				float4 tex2DNode253 = tex2D( _MainTex, uv_MainTex253 );
				float2 uv_StemTexture260 = input.ase_texcoord3.xy;
				float4 tex2DNode260 = tex2D( _StemTexture, uv_StemTexture260 );
				float TextureMask250 = step( 1.5 , input.ase_texcoord3.xy.x );
				float4 lerpResult267 = lerp( tex2DNode253 , tex2DNode260 , TextureMask250);
				float4 TextureColor272 = lerpResult267;
				float DistanceToCenter177 = distance( float2( 0.5,0.5 ) , input.ase_texcoord3.xy );
				float ColorBlendStart173 = _ColorBlendStart;
				float ColorBlendEnd190 = _ColorBlendEnd;
				float4 lerpResult255 = lerp( _FlowerColor1 , _FlowerColor2 , ( saturate( ( ( DistanceToCenter177 - ColorBlendStart173 ) / ColorBlendEnd190 ) ) * step( ColorBlendStart173 , DistanceToCenter177 ) ));
				float4 lerpResult264 = lerp( lerpResult255 , _StemColor , TextureMask250);
				float4 Color274 = lerpResult264;
				float4 Albedo284 = ( TextureColor272 * Color274 );
				
				float lerpResult280 = lerp( tex2DNode253.a , tex2DNode260.a , TextureMask250);
				float Opacity283 = lerpResult280;
				

				float3 BaseColor = Albedo284.rgb;
				float3 Emission = 0;
				float Alpha = Opacity283;
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _AlphaCutoff;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = BaseColor;
				metaInput.Emission = Emission;
				#ifdef EDITOR_VISUALIZATION
					metaInput.VizUV = input.VizUV.xy;
					metaInput.LightCoord = input.LightCoord;
				#endif

				return UnityMetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGB

			HLSLPROGRAM

			#define ASE_GEOMETRY
			#define _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define ASE_VERSION 19908
			#define ASE_SRP_VERSION 170004


			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _ENABLESLOPECORRECTION_ON
			#pragma shader_feature_local _ENABLEHORIZONTALBENDING_ON


			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _NoiseTextureTilling;
			float4 _FlowerColor2;
			float4 _FlowerColor1;
			float4 _StemColor;
			float2 _NoisePannerSpeed;
			float _MBWindDir;
			float _ColorBlendEnd;
			float _ColorBlendStart;
			float _SlopeCorrectionMagnitude;
			float _SlopeCorrectionOffset;
			float _DBHorizontalMaxRadius;
			float _DBHorizontalPhase;
			float _DBHorizontalFrequency;
			float _MBMaxHeight;
			float _MBDefaultBending;
			float _MBPhase;
			float _MBFrequencyOffset;
			float _MBFrequency;
			float _MBAmplitudeOffset;
			float _MBAmplitude;
			float _MBWindDirOffset;
			float _MBWindDirBlend;
			float _DBHorizontalAmplitude;
			float _AlphaCutoff;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float MBGlobalWindDir;
			sampler2D _NoiseTexture;
			sampler2D _MainTex;
			sampler2D _StemTexture;


			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_TRANSFER_INSTANCE_ID( input, output );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output );

				float lerpResult181 = lerp( _MBWindDir , MBGlobalWindDir , _MBWindDirBlend);
				float MB_WindDirection205 = lerpResult181;
				float MB_WindDirectionOffset204 = _MBWindDirOffset;
				float2 texCoord152 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult153 = (float3(texCoord152.x , 0.0 , texCoord152.y));
				float3 LocalPivot154 = -appendResult153;
				float3 objToWorld11_g134 = mul( GetObjectToWorldMatrix(), float4( LocalPivot154, 1 ) ).xyz;
				float2 appendResult10_g134 = (float2(objToWorld11_g134.x , objToWorld11_g134.z));
				float2 UVs27_g135 = appendResult10_g134;
				float4 temp_output_24_0_g135 = _NoiseTextureTilling;
				float2 AnimatedNoiseTilling29_g135 = (temp_output_24_0_g135).zw;
				float2 panner7_g135 = ( 0.1 * _Time.y * _NoisePannerSpeed + float2( 0,0 ));
				float4 AnimatedNoise216 = tex2Dlod( _NoiseTexture, float4( ( ( UVs27_g135 * AnimatedNoiseTilling29_g135 ) + panner7_g135 ), 0, 0.0) );
				float temp_output_11_0_g141 = radians( ( ( MB_WindDirection205 + ( MB_WindDirectionOffset204 *  (-1.0 + ( (AnimatedNoise216).x - 0.0 ) * ( 1.0 - -1.0 ) / ( 1.0 - 0.0 ) ) ) ) * -1.0 ) );
				float3 appendResult14_g141 = (float3(cos( temp_output_11_0_g141 ) , 0.0 , sin( temp_output_11_0_g141 )));
				float3 worldToObj35_g141 = mul( GetWorldToObjectMatrix(), float4( appendResult14_g141, 1 ) ).xyz;
				float3 worldToObj36_g141 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult34_g141 = normalize( (( worldToObj35_g141 - worldToObj36_g141 )).xyz );
				float3 MB_RotationAxis246 = normalizeResult34_g141;
				float3 RotationAxis56_g143 = MB_RotationAxis246;
				float MB_Amplitude207 = _MBAmplitude;
				float MB_AmplitudeOffset218 = _MBAmplitudeOffset;
				float2 StaticNoileTilling28_g135 = (temp_output_24_0_g135).xy;
				float4 StaticNoise202 = tex2Dlod( _NoiseTexture, float4( ( UVs27_g135 * StaticNoileTilling28_g135 ), 0, 0.0) );
				float4 StaticWorldNoise31_g142 = StaticNoise202;
				float3 objToWorld52_g142 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float MB_Frequency215 = _MBFrequency;
				float MB_FrequencyOffset209 = _MBFrequencyOffset;
				float DB_PhaseShift194 = input.ase_color.a;
				float MB_Phase208 = _MBPhase;
				float MB_DefaultBending206 = _MBDefaultBending;
				float MB_MaxHeight211 = _MBMaxHeight;
				float MB_RotationAngle245 = radians( ( ( ( ( MB_Amplitude207 + ( MB_AmplitudeOffset218 * (StaticWorldNoise31_g142).x ) ) * sin( ( ( ( objToWorld52_g142.x + objToWorld52_g142.z ) + ( ( ( _TimeParameters.x ) * ( MB_Frequency215 + ( MB_FrequencyOffset209 * (StaticWorldNoise31_g142).x ) ) ) + ( ( 2.0 * PI ) * DB_PhaseShift194 ) ) ) * MB_Phase208 ) ) ) + MB_DefaultBending206 ) * ( input.positionOS.xyz.y / MB_MaxHeight211 ) ) );
				float RotationAngle54_g143 = MB_RotationAngle245;
				float3 PivotPoint60_g143 = LocalPivot154;
				float3 break62_g143 = PivotPoint60_g143;
				float3 appendResult45_g143 = (float3(break62_g143.x , input.positionOS.xyz.y , break62_g143.z));
				float3 rotatedValue30_g143 = RotateAroundAxis( appendResult45_g143, input.positionOS.xyz, RotationAxis56_g143, RotationAngle54_g143 );
				float DB_HorizontalAmplitude189 = _DBHorizontalAmplitude;
				float DB_HorizontalFrequency193 = _DBHorizontalFrequency;
				float Frequency41_g136 = DB_HorizontalFrequency193;
				float3 objToWorld53_g136 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float DB_HorizontalPhase187 = _DBHorizontalPhase;
				float3 PivotPoint49_g136 = LocalPivot154;
				float3 break52_g136 = PivotPoint49_g136;
				float3 appendResult20_g136 = (float3(break52_g136.x , input.positionOS.xyz.y , break52_g136.z));
				float DB_HorizontalMaxRadius192 = _DBHorizontalMaxRadius;
				float3 rotatedValue33_g136 = RotateAroundAxis( PivotPoint49_g136, input.positionOS.xyz, float3( 0, 1, 0 ), radians( ( ( DB_HorizontalAmplitude189 * sin( ( ( ( ( _TimeParameters.x ) * Frequency41_g136 ) - ( ( 2.0 * PI ) * ( 1.0 - DB_PhaseShift194 ) ) ) + ( ( ( objToWorld53_g136.x + objToWorld53_g136.z ) + ( ( _TimeParameters.x ) * Frequency41_g136 ) ) * DB_HorizontalPhase187 ) ) ) ) * ( distance( input.positionOS.xyz , appendResult20_g136 ) / DB_HorizontalMaxRadius192 ) ) ) );
				#ifdef _ENABLEHORIZONTALBENDING_ON
				float3 staticSwitch242 = ( ( rotatedValue33_g136 - input.positionOS.xyz ) * 1.0 );
				#else
				float3 staticSwitch242 = float3( 0, 0, 0 );
				#endif
				float3 DB_VertexOffset248 = staticSwitch242;
				float3 rotatedValue34_g143 = RotateAroundAxis( PivotPoint60_g143, ( rotatedValue30_g143 + DB_VertexOffset248 ), RotationAxis56_g143, RotationAngle54_g143 );
				float3 temp_output_265_0 = ( ( rotatedValue34_g143 - input.positionOS.xyz ) * step( 0.01 , input.positionOS.xyz.y ) );
				float3 MainBending89_g144 = temp_output_265_0;
				float3 appendResult15_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld98_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult15_g144, 1 ) ).xyz;
				float3 objToWorld102_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 break20_g144 = ( objToWorld98_g144 - objToWorld102_g144 );
				float3 appendResult24_g144 = (float3(-break20_g144.z , 0.0 , break20_g144.x));
				float3 appendResult3_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld100_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult3_g144, 1 ) ).xyz;
				float3 objToWorld106_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 temp_output_107_0_g144 = ( objToWorld100_g144 - objToWorld106_g144 );
				float3 break108_g144 = temp_output_107_0_g144;
				float3 lerpResult84_g144 = lerp( float3( 0, 1, 0 ) , temp_output_107_0_g144 , step( 0.001 , ( abs( break108_g144.x ) + abs( break108_g144.z ) ) ));
				float3 normalizeResult7_g144 = normalize( lerpResult84_g144 );
				float dotResult9_g144 = dot( normalizeResult7_g144 , float3( 0, 1, 0 ) );
				float temp_output_12_0_g144 = acos( dotResult9_g144 );
				float NaNPrevention21_g144 = step( 0.01 , abs( ( temp_output_12_0_g144 * ( 180.0 / PI ) ) ) );
				float3 lerpResult26_g144 = lerp( float3( 1, 0, 0 ) , appendResult24_g144 , NaNPrevention21_g144);
				float3 worldToObj99_g144 = mul( GetWorldToObjectMatrix(), float4( lerpResult26_g144, 1 ) ).xyz;
				float3 worldToObj105_g144 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult49_g144 = normalize( ( worldToObj99_g144 - worldToObj105_g144 ) );
				float3 RotationAxis30_g144 = normalizeResult49_g144;
				float SlopeCorrectionOffset269 = _SlopeCorrectionOffset;
				float SlopeCorrectionMagnitude268 = _SlopeCorrectionMagnitude;
				float RotationAngle29_g144 = ( saturate( (  (0.0 + ( (StaticNoise202).x - 0.0 ) * ( SlopeCorrectionOffset269 - 0.0 ) / ( 1.0 - 0.0 ) ) + SlopeCorrectionMagnitude268 ) ) * temp_output_12_0_g144 );
				float3 rotatedValue35_g144 = RotateAroundAxis( LocalPivot154, ( input.positionOS.xyz + MainBending89_g144 ), RotationAxis30_g144, RotationAngle29_g144 );
				float3 lerpResult52_g144 = lerp( MainBending89_g144 , ( rotatedValue35_g144 - input.positionOS.xyz ) , NaNPrevention21_g144);
				#ifdef _ENABLESLOPECORRECTION_ON
				float3 staticSwitch282 = lerpResult52_g144;
				#else
				float3 staticSwitch282 = temp_output_265_0;
				#endif
				float3 LocalVertexOffset285 = staticSwitch282;
				
				output.ase_texcoord1.xy = input.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord1.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = LocalVertexOffset285;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				output.ase_texcoord = input.ase_texcoord;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( input.positionWS );
				float4 ShadowCoord = shadowCoord;

				float2 uv_MainTex253 = input.ase_texcoord1.xy;
				float4 tex2DNode253 = tex2D( _MainTex, uv_MainTex253 );
				float2 uv_StemTexture260 = input.ase_texcoord1.xy;
				float4 tex2DNode260 = tex2D( _StemTexture, uv_StemTexture260 );
				float TextureMask250 = step( 1.5 , input.ase_texcoord1.xy.x );
				float4 lerpResult267 = lerp( tex2DNode253 , tex2DNode260 , TextureMask250);
				float4 TextureColor272 = lerpResult267;
				float DistanceToCenter177 = distance( float2( 0.5,0.5 ) , input.ase_texcoord1.xy );
				float ColorBlendStart173 = _ColorBlendStart;
				float ColorBlendEnd190 = _ColorBlendEnd;
				float4 lerpResult255 = lerp( _FlowerColor1 , _FlowerColor2 , ( saturate( ( ( DistanceToCenter177 - ColorBlendStart173 ) / ColorBlendEnd190 ) ) * step( ColorBlendStart173 , DistanceToCenter177 ) ));
				float4 lerpResult264 = lerp( lerpResult255 , _StemColor , TextureMask250);
				float4 Color274 = lerpResult264;
				float4 Albedo284 = ( TextureColor272 * Color274 );
				
				float lerpResult280 = lerp( tex2DNode253.a , tex2DNode260.a , TextureMask250);
				float Opacity283 = lerpResult280;
				

				float3 BaseColor = Albedo284.rgb;
				float Alpha = Opacity283;
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _AlphaCutoff;
				#endif

				half4 color = half4(BaseColor, Alpha );

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormals" }

			ZWrite On
			Blend One Zero
			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			#define ASE_GEOMETRY
			#define _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define ASE_VERSION 19908
			#define ASE_SRP_VERSION 170004


			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
			//#define SHADERPASS SHADERPASS_DEPTHNORMALS

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#if defined( UNITY_INSTANCING_ENABLED ) && defined( ASE_INSTANCED_TERRAIN ) && ( defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL) || defined(_INSTANCEDTERRAINNORMALS_PIXEL) )
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _ENABLESLOPECORRECTION_ON
			#pragma shader_feature_local _ENABLEHORIZONTALBENDING_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				half4 texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				half3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2; // holds terrainUV ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _NoiseTextureTilling;
			float4 _FlowerColor2;
			float4 _FlowerColor1;
			float4 _StemColor;
			float2 _NoisePannerSpeed;
			float _MBWindDir;
			float _ColorBlendEnd;
			float _ColorBlendStart;
			float _SlopeCorrectionMagnitude;
			float _SlopeCorrectionOffset;
			float _DBHorizontalMaxRadius;
			float _DBHorizontalPhase;
			float _DBHorizontalFrequency;
			float _MBMaxHeight;
			float _MBDefaultBending;
			float _MBPhase;
			float _MBFrequencyOffset;
			float _MBFrequency;
			float _MBAmplitudeOffset;
			float _MBAmplitude;
			float _MBWindDirOffset;
			float _MBWindDirBlend;
			float _DBHorizontalAmplitude;
			float _AlphaCutoff;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float MBGlobalWindDir;
			sampler2D _NoiseTexture;
			sampler2D _MainTex;
			sampler2D _StemTexture;


			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float lerpResult181 = lerp( _MBWindDir , MBGlobalWindDir , _MBWindDirBlend);
				float MB_WindDirection205 = lerpResult181;
				float MB_WindDirectionOffset204 = _MBWindDirOffset;
				float2 texCoord152 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult153 = (float3(texCoord152.x , 0.0 , texCoord152.y));
				float3 LocalPivot154 = -appendResult153;
				float3 objToWorld11_g134 = mul( GetObjectToWorldMatrix(), float4( LocalPivot154, 1 ) ).xyz;
				float2 appendResult10_g134 = (float2(objToWorld11_g134.x , objToWorld11_g134.z));
				float2 UVs27_g135 = appendResult10_g134;
				float4 temp_output_24_0_g135 = _NoiseTextureTilling;
				float2 AnimatedNoiseTilling29_g135 = (temp_output_24_0_g135).zw;
				float2 panner7_g135 = ( 0.1 * _Time.y * _NoisePannerSpeed + float2( 0,0 ));
				float4 AnimatedNoise216 = tex2Dlod( _NoiseTexture, float4( ( ( UVs27_g135 * AnimatedNoiseTilling29_g135 ) + panner7_g135 ), 0, 0.0) );
				float temp_output_11_0_g141 = radians( ( ( MB_WindDirection205 + ( MB_WindDirectionOffset204 *  (-1.0 + ( (AnimatedNoise216).x - 0.0 ) * ( 1.0 - -1.0 ) / ( 1.0 - 0.0 ) ) ) ) * -1.0 ) );
				float3 appendResult14_g141 = (float3(cos( temp_output_11_0_g141 ) , 0.0 , sin( temp_output_11_0_g141 )));
				float3 worldToObj35_g141 = mul( GetWorldToObjectMatrix(), float4( appendResult14_g141, 1 ) ).xyz;
				float3 worldToObj36_g141 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult34_g141 = normalize( (( worldToObj35_g141 - worldToObj36_g141 )).xyz );
				float3 MB_RotationAxis246 = normalizeResult34_g141;
				float3 RotationAxis56_g143 = MB_RotationAxis246;
				float MB_Amplitude207 = _MBAmplitude;
				float MB_AmplitudeOffset218 = _MBAmplitudeOffset;
				float2 StaticNoileTilling28_g135 = (temp_output_24_0_g135).xy;
				float4 StaticNoise202 = tex2Dlod( _NoiseTexture, float4( ( UVs27_g135 * StaticNoileTilling28_g135 ), 0, 0.0) );
				float4 StaticWorldNoise31_g142 = StaticNoise202;
				float3 objToWorld52_g142 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float MB_Frequency215 = _MBFrequency;
				float MB_FrequencyOffset209 = _MBFrequencyOffset;
				float DB_PhaseShift194 = input.ase_color.a;
				float MB_Phase208 = _MBPhase;
				float MB_DefaultBending206 = _MBDefaultBending;
				float MB_MaxHeight211 = _MBMaxHeight;
				float MB_RotationAngle245 = radians( ( ( ( ( MB_Amplitude207 + ( MB_AmplitudeOffset218 * (StaticWorldNoise31_g142).x ) ) * sin( ( ( ( objToWorld52_g142.x + objToWorld52_g142.z ) + ( ( ( _TimeParameters.x ) * ( MB_Frequency215 + ( MB_FrequencyOffset209 * (StaticWorldNoise31_g142).x ) ) ) + ( ( 2.0 * PI ) * DB_PhaseShift194 ) ) ) * MB_Phase208 ) ) ) + MB_DefaultBending206 ) * ( input.positionOS.xyz.y / MB_MaxHeight211 ) ) );
				float RotationAngle54_g143 = MB_RotationAngle245;
				float3 PivotPoint60_g143 = LocalPivot154;
				float3 break62_g143 = PivotPoint60_g143;
				float3 appendResult45_g143 = (float3(break62_g143.x , input.positionOS.xyz.y , break62_g143.z));
				float3 rotatedValue30_g143 = RotateAroundAxis( appendResult45_g143, input.positionOS.xyz, RotationAxis56_g143, RotationAngle54_g143 );
				float DB_HorizontalAmplitude189 = _DBHorizontalAmplitude;
				float DB_HorizontalFrequency193 = _DBHorizontalFrequency;
				float Frequency41_g136 = DB_HorizontalFrequency193;
				float3 objToWorld53_g136 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float DB_HorizontalPhase187 = _DBHorizontalPhase;
				float3 PivotPoint49_g136 = LocalPivot154;
				float3 break52_g136 = PivotPoint49_g136;
				float3 appendResult20_g136 = (float3(break52_g136.x , input.positionOS.xyz.y , break52_g136.z));
				float DB_HorizontalMaxRadius192 = _DBHorizontalMaxRadius;
				float3 rotatedValue33_g136 = RotateAroundAxis( PivotPoint49_g136, input.positionOS.xyz, float3( 0, 1, 0 ), radians( ( ( DB_HorizontalAmplitude189 * sin( ( ( ( ( _TimeParameters.x ) * Frequency41_g136 ) - ( ( 2.0 * PI ) * ( 1.0 - DB_PhaseShift194 ) ) ) + ( ( ( objToWorld53_g136.x + objToWorld53_g136.z ) + ( ( _TimeParameters.x ) * Frequency41_g136 ) ) * DB_HorizontalPhase187 ) ) ) ) * ( distance( input.positionOS.xyz , appendResult20_g136 ) / DB_HorizontalMaxRadius192 ) ) ) );
				#ifdef _ENABLEHORIZONTALBENDING_ON
				float3 staticSwitch242 = ( ( rotatedValue33_g136 - input.positionOS.xyz ) * 1.0 );
				#else
				float3 staticSwitch242 = float3( 0, 0, 0 );
				#endif
				float3 DB_VertexOffset248 = staticSwitch242;
				float3 rotatedValue34_g143 = RotateAroundAxis( PivotPoint60_g143, ( rotatedValue30_g143 + DB_VertexOffset248 ), RotationAxis56_g143, RotationAngle54_g143 );
				float3 temp_output_265_0 = ( ( rotatedValue34_g143 - input.positionOS.xyz ) * step( 0.01 , input.positionOS.xyz.y ) );
				float3 MainBending89_g144 = temp_output_265_0;
				float3 appendResult15_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld98_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult15_g144, 1 ) ).xyz;
				float3 objToWorld102_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 break20_g144 = ( objToWorld98_g144 - objToWorld102_g144 );
				float3 appendResult24_g144 = (float3(-break20_g144.z , 0.0 , break20_g144.x));
				float3 appendResult3_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld100_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult3_g144, 1 ) ).xyz;
				float3 objToWorld106_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 temp_output_107_0_g144 = ( objToWorld100_g144 - objToWorld106_g144 );
				float3 break108_g144 = temp_output_107_0_g144;
				float3 lerpResult84_g144 = lerp( float3( 0, 1, 0 ) , temp_output_107_0_g144 , step( 0.001 , ( abs( break108_g144.x ) + abs( break108_g144.z ) ) ));
				float3 normalizeResult7_g144 = normalize( lerpResult84_g144 );
				float dotResult9_g144 = dot( normalizeResult7_g144 , float3( 0, 1, 0 ) );
				float temp_output_12_0_g144 = acos( dotResult9_g144 );
				float NaNPrevention21_g144 = step( 0.01 , abs( ( temp_output_12_0_g144 * ( 180.0 / PI ) ) ) );
				float3 lerpResult26_g144 = lerp( float3( 1, 0, 0 ) , appendResult24_g144 , NaNPrevention21_g144);
				float3 worldToObj99_g144 = mul( GetWorldToObjectMatrix(), float4( lerpResult26_g144, 1 ) ).xyz;
				float3 worldToObj105_g144 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult49_g144 = normalize( ( worldToObj99_g144 - worldToObj105_g144 ) );
				float3 RotationAxis30_g144 = normalizeResult49_g144;
				float SlopeCorrectionOffset269 = _SlopeCorrectionOffset;
				float SlopeCorrectionMagnitude268 = _SlopeCorrectionMagnitude;
				float RotationAngle29_g144 = ( saturate( (  (0.0 + ( (StaticNoise202).x - 0.0 ) * ( SlopeCorrectionOffset269 - 0.0 ) / ( 1.0 - 0.0 ) ) + SlopeCorrectionMagnitude268 ) ) * temp_output_12_0_g144 );
				float3 rotatedValue35_g144 = RotateAroundAxis( LocalPivot154, ( input.positionOS.xyz + MainBending89_g144 ), RotationAxis30_g144, RotationAngle29_g144 );
				float3 lerpResult52_g144 = lerp( MainBending89_g144 , ( rotatedValue35_g144 - input.positionOS.xyz ) , NaNPrevention21_g144);
				#ifdef _ENABLESLOPECORRECTION_ON
				float3 staticSwitch282 = lerpResult52_g144;
				#else
				float3 staticSwitch282 = temp_output_265_0;
				#endif
				float3 LocalVertexOffset285 = staticSwitch282;
				
				output.ase_texcoord3.xy = input.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = LocalVertexOffset285;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				output.positionCS = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				output.normalWS = normalInput.normalWS;
				output.tangentWS = float4( normalInput.tangentWS, ( input.tangentOS.w > 0.0 ? 1.0 : -1.0 ) * GetOddNegativeScale() );

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					output.tangentWS.zw = input.texcoord.xy;
					output.tangentWS.xy = input.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.texcoord = input.texcoord;
				output.texcoord = input.texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				output.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			void frag(	PackedVaryings input
						, out half4 outNormalWS : SV_Target0
						#if defined( ASE_DEPTH_WRITE_ON )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 )
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				// @diogo: mikktspace compliant
				float renormFactor = 1.0 / max( FLT_MIN, length( input.normalWS ) );

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( input.positionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );
				float3 TangentWS = input.tangentWS.xyz * renormFactor;
				float3 BitangentWS = cross( input.normalWS, input.tangentWS.xyz ) * input.tangentWS.w * renormFactor;
				float3 NormalWS = input.normalWS * renormFactor;

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					float2 sampleCoords = (input.tangentWS.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					NormalWS = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					TangentWS = -cross(GetObjectToWorldMatrix()._13_23_33, NormalWS);
					BitangentWS = cross(NormalWS, -TangentWS);
				#endif

				float2 uv_MainTex253 = input.ase_texcoord3.xy;
				float4 tex2DNode253 = tex2D( _MainTex, uv_MainTex253 );
				float2 uv_StemTexture260 = input.ase_texcoord3.xy;
				float4 tex2DNode260 = tex2D( _StemTexture, uv_StemTexture260 );
				float TextureMask250 = step( 1.5 , input.ase_texcoord3.xy.x );
				float lerpResult280 = lerp( tex2DNode253.a , tex2DNode260.a , TextureMask250);
				float Opacity283 = lerpResult280;
				

				float3 Normal = float3(0, 0, 1);
				float Alpha = Opacity283;
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _AlphaCutoff;
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float2 octNormalWS = PackNormalOctQuadEncode(NormalWS);
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					#if defined(_NORMALMAP)
						#if _NORMAL_DROPOFF_TS
							float3 normalWS = TransformTangentToWorld(Normal, half3x3(TangentWS, BitangentWS, NormalWS));
						#elif _NORMAL_DROPOFF_OS
							float3 normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							float3 normalWS = Normal;
						#endif
					#else
						float3 normalWS = NormalWS;
					#endif
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGB
			

			HLSLPROGRAM

			#define ASE_GEOMETRY
			#define _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define ASE_VERSION 19908
			#define ASE_SRP_VERSION 170004


			// Deferred Rendering Path does not support the OpenGL-based graphics API:
			// Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
			#pragma exclude_renderers glcore gles3 switch2 webgpu 

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#if ( UNITY_VERSION >= 60000058 )
			#pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
			#endif
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ USE_LEGACY_LIGHTMAPS
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_GBUFFER

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#if defined( UNITY_INSTANCING_ENABLED ) && defined( ASE_INSTANCED_TERRAIN ) && ( defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL) || defined(_INSTANCEDTERRAINNORMALS_PIXEL) )
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _ENABLESLOPECORRECTION_ON
			#pragma shader_feature_local _ENABLEHORIZONTALBENDING_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					float4 texcoord1 : TEXCOORD1;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					float4 texcoord2 : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				half3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2; // holds terrainUV ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
				float4 lightmapUVOrVertexSH : TEXCOORD3;
				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					half4 fogFactorAndVertexLight : TEXCOORD4;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV : TEXCOORD5;
				#endif
				#if defined(USE_APV_PROBE_OCCLUSION)
					float4 probeOcclusion : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _NoiseTextureTilling;
			float4 _FlowerColor2;
			float4 _FlowerColor1;
			float4 _StemColor;
			float2 _NoisePannerSpeed;
			float _MBWindDir;
			float _ColorBlendEnd;
			float _ColorBlendStart;
			float _SlopeCorrectionMagnitude;
			float _SlopeCorrectionOffset;
			float _DBHorizontalMaxRadius;
			float _DBHorizontalPhase;
			float _DBHorizontalFrequency;
			float _MBMaxHeight;
			float _MBDefaultBending;
			float _MBPhase;
			float _MBFrequencyOffset;
			float _MBFrequency;
			float _MBAmplitudeOffset;
			float _MBAmplitude;
			float _MBWindDirOffset;
			float _MBWindDirBlend;
			float _DBHorizontalAmplitude;
			float _AlphaCutoff;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float MBGlobalWindDir;
			sampler2D _NoiseTexture;
			sampler2D _MainTex;
			sampler2D _StemTexture;


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float lerpResult181 = lerp( _MBWindDir , MBGlobalWindDir , _MBWindDirBlend);
				float MB_WindDirection205 = lerpResult181;
				float MB_WindDirectionOffset204 = _MBWindDirOffset;
				float2 texCoord152 = input.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult153 = (float3(texCoord152.x , 0.0 , texCoord152.y));
				float3 LocalPivot154 = -appendResult153;
				float3 objToWorld11_g134 = mul( GetObjectToWorldMatrix(), float4( LocalPivot154, 1 ) ).xyz;
				float2 appendResult10_g134 = (float2(objToWorld11_g134.x , objToWorld11_g134.z));
				float2 UVs27_g135 = appendResult10_g134;
				float4 temp_output_24_0_g135 = _NoiseTextureTilling;
				float2 AnimatedNoiseTilling29_g135 = (temp_output_24_0_g135).zw;
				float2 panner7_g135 = ( 0.1 * _Time.y * _NoisePannerSpeed + float2( 0,0 ));
				float4 AnimatedNoise216 = tex2Dlod( _NoiseTexture, float4( ( ( UVs27_g135 * AnimatedNoiseTilling29_g135 ) + panner7_g135 ), 0, 0.0) );
				float temp_output_11_0_g141 = radians( ( ( MB_WindDirection205 + ( MB_WindDirectionOffset204 *  (-1.0 + ( (AnimatedNoise216).x - 0.0 ) * ( 1.0 - -1.0 ) / ( 1.0 - 0.0 ) ) ) ) * -1.0 ) );
				float3 appendResult14_g141 = (float3(cos( temp_output_11_0_g141 ) , 0.0 , sin( temp_output_11_0_g141 )));
				float3 worldToObj35_g141 = mul( GetWorldToObjectMatrix(), float4( appendResult14_g141, 1 ) ).xyz;
				float3 worldToObj36_g141 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult34_g141 = normalize( (( worldToObj35_g141 - worldToObj36_g141 )).xyz );
				float3 MB_RotationAxis246 = normalizeResult34_g141;
				float3 RotationAxis56_g143 = MB_RotationAxis246;
				float MB_Amplitude207 = _MBAmplitude;
				float MB_AmplitudeOffset218 = _MBAmplitudeOffset;
				float2 StaticNoileTilling28_g135 = (temp_output_24_0_g135).xy;
				float4 StaticNoise202 = tex2Dlod( _NoiseTexture, float4( ( UVs27_g135 * StaticNoileTilling28_g135 ), 0, 0.0) );
				float4 StaticWorldNoise31_g142 = StaticNoise202;
				float3 objToWorld52_g142 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float MB_Frequency215 = _MBFrequency;
				float MB_FrequencyOffset209 = _MBFrequencyOffset;
				float DB_PhaseShift194 = input.ase_color.a;
				float MB_Phase208 = _MBPhase;
				float MB_DefaultBending206 = _MBDefaultBending;
				float MB_MaxHeight211 = _MBMaxHeight;
				float MB_RotationAngle245 = radians( ( ( ( ( MB_Amplitude207 + ( MB_AmplitudeOffset218 * (StaticWorldNoise31_g142).x ) ) * sin( ( ( ( objToWorld52_g142.x + objToWorld52_g142.z ) + ( ( ( _TimeParameters.x ) * ( MB_Frequency215 + ( MB_FrequencyOffset209 * (StaticWorldNoise31_g142).x ) ) ) + ( ( 2.0 * PI ) * DB_PhaseShift194 ) ) ) * MB_Phase208 ) ) ) + MB_DefaultBending206 ) * ( input.positionOS.xyz.y / MB_MaxHeight211 ) ) );
				float RotationAngle54_g143 = MB_RotationAngle245;
				float3 PivotPoint60_g143 = LocalPivot154;
				float3 break62_g143 = PivotPoint60_g143;
				float3 appendResult45_g143 = (float3(break62_g143.x , input.positionOS.xyz.y , break62_g143.z));
				float3 rotatedValue30_g143 = RotateAroundAxis( appendResult45_g143, input.positionOS.xyz, RotationAxis56_g143, RotationAngle54_g143 );
				float DB_HorizontalAmplitude189 = _DBHorizontalAmplitude;
				float DB_HorizontalFrequency193 = _DBHorizontalFrequency;
				float Frequency41_g136 = DB_HorizontalFrequency193;
				float3 objToWorld53_g136 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float DB_HorizontalPhase187 = _DBHorizontalPhase;
				float3 PivotPoint49_g136 = LocalPivot154;
				float3 break52_g136 = PivotPoint49_g136;
				float3 appendResult20_g136 = (float3(break52_g136.x , input.positionOS.xyz.y , break52_g136.z));
				float DB_HorizontalMaxRadius192 = _DBHorizontalMaxRadius;
				float3 rotatedValue33_g136 = RotateAroundAxis( PivotPoint49_g136, input.positionOS.xyz, float3( 0, 1, 0 ), radians( ( ( DB_HorizontalAmplitude189 * sin( ( ( ( ( _TimeParameters.x ) * Frequency41_g136 ) - ( ( 2.0 * PI ) * ( 1.0 - DB_PhaseShift194 ) ) ) + ( ( ( objToWorld53_g136.x + objToWorld53_g136.z ) + ( ( _TimeParameters.x ) * Frequency41_g136 ) ) * DB_HorizontalPhase187 ) ) ) ) * ( distance( input.positionOS.xyz , appendResult20_g136 ) / DB_HorizontalMaxRadius192 ) ) ) );
				#ifdef _ENABLEHORIZONTALBENDING_ON
				float3 staticSwitch242 = ( ( rotatedValue33_g136 - input.positionOS.xyz ) * 1.0 );
				#else
				float3 staticSwitch242 = float3( 0, 0, 0 );
				#endif
				float3 DB_VertexOffset248 = staticSwitch242;
				float3 rotatedValue34_g143 = RotateAroundAxis( PivotPoint60_g143, ( rotatedValue30_g143 + DB_VertexOffset248 ), RotationAxis56_g143, RotationAngle54_g143 );
				float3 temp_output_265_0 = ( ( rotatedValue34_g143 - input.positionOS.xyz ) * step( 0.01 , input.positionOS.xyz.y ) );
				float3 MainBending89_g144 = temp_output_265_0;
				float3 appendResult15_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld98_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult15_g144, 1 ) ).xyz;
				float3 objToWorld102_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 break20_g144 = ( objToWorld98_g144 - objToWorld102_g144 );
				float3 appendResult24_g144 = (float3(-break20_g144.z , 0.0 , break20_g144.x));
				float3 appendResult3_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld100_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult3_g144, 1 ) ).xyz;
				float3 objToWorld106_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 temp_output_107_0_g144 = ( objToWorld100_g144 - objToWorld106_g144 );
				float3 break108_g144 = temp_output_107_0_g144;
				float3 lerpResult84_g144 = lerp( float3( 0, 1, 0 ) , temp_output_107_0_g144 , step( 0.001 , ( abs( break108_g144.x ) + abs( break108_g144.z ) ) ));
				float3 normalizeResult7_g144 = normalize( lerpResult84_g144 );
				float dotResult9_g144 = dot( normalizeResult7_g144 , float3( 0, 1, 0 ) );
				float temp_output_12_0_g144 = acos( dotResult9_g144 );
				float NaNPrevention21_g144 = step( 0.01 , abs( ( temp_output_12_0_g144 * ( 180.0 / PI ) ) ) );
				float3 lerpResult26_g144 = lerp( float3( 1, 0, 0 ) , appendResult24_g144 , NaNPrevention21_g144);
				float3 worldToObj99_g144 = mul( GetWorldToObjectMatrix(), float4( lerpResult26_g144, 1 ) ).xyz;
				float3 worldToObj105_g144 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult49_g144 = normalize( ( worldToObj99_g144 - worldToObj105_g144 ) );
				float3 RotationAxis30_g144 = normalizeResult49_g144;
				float SlopeCorrectionOffset269 = _SlopeCorrectionOffset;
				float SlopeCorrectionMagnitude268 = _SlopeCorrectionMagnitude;
				float RotationAngle29_g144 = ( saturate( (  (0.0 + ( (StaticNoise202).x - 0.0 ) * ( SlopeCorrectionOffset269 - 0.0 ) / ( 1.0 - 0.0 ) ) + SlopeCorrectionMagnitude268 ) ) * temp_output_12_0_g144 );
				float3 rotatedValue35_g144 = RotateAroundAxis( LocalPivot154, ( input.positionOS.xyz + MainBending89_g144 ), RotationAxis30_g144, RotationAngle29_g144 );
				float3 lerpResult52_g144 = lerp( MainBending89_g144 , ( rotatedValue35_g144 - input.positionOS.xyz ) , NaNPrevention21_g144);
				#ifdef _ENABLESLOPECORRECTION_ON
				float3 staticSwitch282 = lerpResult52_g144;
				#else
				float3 staticSwitch282 = temp_output_265_0;
				#endif
				float3 LocalVertexOffset285 = staticSwitch282;
				
				output.ase_texcoord7.xy = input.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = LocalVertexOffset285;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				OUTPUT_LIGHTMAP_UV(input.texcoord1, unity_LightmapST, output.lightmapUVOrVertexSH.xy);
				#if defined(DYNAMICLIGHTMAP_ON)
					output.dynamicLightmapUV.xy = input.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif
				OUTPUT_SH4(vertexInput.positionWS, normalInput.normalWS.xyz, GetWorldSpaceNormalizeViewDir(vertexInput.positionWS), output.lightmapUVOrVertexSH.xyz, output.probeOcclusion);

				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					output.fogFactorAndVertexLight = 0;
					#if defined(ASE_FOG) && !defined(_FOG_FRAGMENT)
						// @diogo: no fog applied in GBuffer
					#endif
					#ifdef _ADDITIONAL_LIGHTS_VERTEX
						half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );
						output.fogFactorAndVertexLight.yzw = vertexLight;
					#endif
				#endif

				output.positionCS = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				output.normalWS = normalInput.normalWS;
				output.tangentWS = float4( normalInput.tangentWS, ( input.tangentOS.w > 0.0 ? 1.0 : -1.0 ) * GetOddNegativeScale() );

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					output.tangentWS.zw = input.texcoord.xy;
					output.tangentWS.xy = input.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					float4 texcoord1 : TEXCOORD1;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					float4 texcoord2 : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.texcoord = input.texcoord;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					output.texcoord1 = input.texcoord1;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					output.texcoord2 = input.texcoord2;
				#endif
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					output.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					output.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				#endif
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			FragmentOutput frag ( PackedVaryings input
								#if defined( ASE_DEPTH_WRITE_ON )
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					float4 shadowCoord = TransformWorldToShadowCoord( input.positionWS );
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				// @diogo: mikktspace compliant
				float renormFactor = 1.0 / max( FLT_MIN, length( input.normalWS ) );

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				float3 ViewDirWS = GetWorldSpaceNormalizeViewDir( PositionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );
				float3 TangentWS = input.tangentWS.xyz * renormFactor;
				float3 BitangentWS = cross( input.normalWS, input.tangentWS.xyz ) * input.tangentWS.w * renormFactor;
				float3 NormalWS = input.normalWS * renormFactor;

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					float2 sampleCoords = (input.tangentWS.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					NormalWS = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					TangentWS = -cross(GetObjectToWorldMatrix()._13_23_33, NormalWS);
					BitangentWS = cross(NormalWS, -TangentWS);
				#endif

				float2 uv_MainTex253 = input.ase_texcoord7.xy;
				float4 tex2DNode253 = tex2D( _MainTex, uv_MainTex253 );
				float2 uv_StemTexture260 = input.ase_texcoord7.xy;
				float4 tex2DNode260 = tex2D( _StemTexture, uv_StemTexture260 );
				float TextureMask250 = step( 1.5 , input.ase_texcoord7.xy.x );
				float4 lerpResult267 = lerp( tex2DNode253 , tex2DNode260 , TextureMask250);
				float4 TextureColor272 = lerpResult267;
				float DistanceToCenter177 = distance( float2( 0.5,0.5 ) , input.ase_texcoord7.xy );
				float ColorBlendStart173 = _ColorBlendStart;
				float ColorBlendEnd190 = _ColorBlendEnd;
				float4 lerpResult255 = lerp( _FlowerColor1 , _FlowerColor2 , ( saturate( ( ( DistanceToCenter177 - ColorBlendStart173 ) / ColorBlendEnd190 ) ) * step( ColorBlendStart173 , DistanceToCenter177 ) ));
				float4 lerpResult264 = lerp( lerpResult255 , _StemColor , TextureMask250);
				float4 Color274 = lerpResult264;
				float4 Albedo284 = ( TextureColor272 * Color274 );
				
				float lerpResult280 = lerp( tex2DNode253.a , tex2DNode260.a , TextureMask250);
				float Opacity283 = lerpResult280;
				

				float3 BaseColor = Albedo284.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Specular = 0.5;
				float Metallic = 0.0;
				float Smoothness = 0.0;
				float Occlusion = 1;
				float3 Emission = 0;
				float Alpha = Opacity283;
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _AlphaCutoff;
					float AlphaClipThresholdShadow = 0.5;
				#endif
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_CHANGES_WORLD_POS)
					ShadowCoord = TransformWorldToShadowCoord( PositionWS );
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = PositionWS;
				inputData.positionCS = input.positionCS;
				inputData.normalizedScreenSpaceUV = ScreenPosNorm.xy;
				inputData.shadowCoord = ShadowCoord;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
						inputData.normalWS = TransformTangentToWorld(Normal, half3x3( TangentWS, BitangentWS, NormalWS ));
					#elif _NORMAL_DROPOFF_OS
						inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
						inputData.normalWS = Normal;
					#endif
				#else
					inputData.normalWS = NormalWS;
				#endif

				inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				inputData.viewDirectionWS = SafeNormalize( ViewDirWS );

				#ifdef ASE_FOG
					// @diogo: no fog applied in GBuffer
				#endif
				#ifdef _ADDITIONAL_LIGHTS_VERTEX
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				#endif

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = input.lightmapUVOrVertexSH.xyz;
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, input.dynamicLightmapUV.xy, SH, inputData.normalWS);
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUVOrVertexSH.xy);
				#elif !defined(LIGHTMAP_ON) && (defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2))
					inputData.bakedGI = SAMPLE_GI(SH,
						GetAbsolutePositionWS(inputData.positionWS),
						inputData.normalWS,
						inputData.viewDirectionWS,
						input.positionCS.xy,
						input.probeOcclusion,
						inputData.shadowMask);
				#else
					inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUVOrVertexSH.xy);
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
						#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = input.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
					#if defined(USE_APV_PROBE_OCCLUSION)
						inputData.probeOcclusion = input.probeOcclusion;
					#endif
				#endif

				#ifdef _DBUFFER
					ApplyDecal(input.positionCS,
						BaseColor,
						Specular,
						inputData.normalWS,
						Metallic,
						Occlusion,
						Smoothness);
				#endif

				BRDFData brdfData;
				InitializeBRDFData(BaseColor, Metallic, Specular, Smoothness, Alpha, brdfData);

				Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
				half4 color;
				MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);
				color.rgb = GlobalIllumination(brdfData, inputData.bakedGI, Occlusion, inputData.positionWS, inputData.normalWS, inputData.viewDirectionWS);
				color.a = Alpha;

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				return BRDFDataToGbuffer(brdfData, inputData, Smoothness, Emission + color.rgb, Occlusion);
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			Cull Off
			AlphaToMask Off

			HLSLPROGRAM

			#define ASE_GEOMETRY
			#define _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define ASE_VERSION 19908
			#define ASE_SRP_VERSION 170004


			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SCENESELECTIONPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _ENABLESLOPECORRECTION_ON
			#pragma shader_feature_local _ENABLEHORIZONTALBENDING_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _NoiseTextureTilling;
			float4 _FlowerColor2;
			float4 _FlowerColor1;
			float4 _StemColor;
			float2 _NoisePannerSpeed;
			float _MBWindDir;
			float _ColorBlendEnd;
			float _ColorBlendStart;
			float _SlopeCorrectionMagnitude;
			float _SlopeCorrectionOffset;
			float _DBHorizontalMaxRadius;
			float _DBHorizontalPhase;
			float _DBHorizontalFrequency;
			float _MBMaxHeight;
			float _MBDefaultBending;
			float _MBPhase;
			float _MBFrequencyOffset;
			float _MBFrequency;
			float _MBAmplitudeOffset;
			float _MBAmplitude;
			float _MBWindDirOffset;
			float _MBWindDirBlend;
			float _DBHorizontalAmplitude;
			float _AlphaCutoff;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float MBGlobalWindDir;
			sampler2D _NoiseTexture;
			sampler2D _MainTex;
			sampler2D _StemTexture;


			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			PackedVaryings VertexFunction(Attributes input  )
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float lerpResult181 = lerp( _MBWindDir , MBGlobalWindDir , _MBWindDirBlend);
				float MB_WindDirection205 = lerpResult181;
				float MB_WindDirectionOffset204 = _MBWindDirOffset;
				float2 texCoord152 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult153 = (float3(texCoord152.x , 0.0 , texCoord152.y));
				float3 LocalPivot154 = -appendResult153;
				float3 objToWorld11_g134 = mul( GetObjectToWorldMatrix(), float4( LocalPivot154, 1 ) ).xyz;
				float2 appendResult10_g134 = (float2(objToWorld11_g134.x , objToWorld11_g134.z));
				float2 UVs27_g135 = appendResult10_g134;
				float4 temp_output_24_0_g135 = _NoiseTextureTilling;
				float2 AnimatedNoiseTilling29_g135 = (temp_output_24_0_g135).zw;
				float2 panner7_g135 = ( 0.1 * _Time.y * _NoisePannerSpeed + float2( 0,0 ));
				float4 AnimatedNoise216 = tex2Dlod( _NoiseTexture, float4( ( ( UVs27_g135 * AnimatedNoiseTilling29_g135 ) + panner7_g135 ), 0, 0.0) );
				float temp_output_11_0_g141 = radians( ( ( MB_WindDirection205 + ( MB_WindDirectionOffset204 *  (-1.0 + ( (AnimatedNoise216).x - 0.0 ) * ( 1.0 - -1.0 ) / ( 1.0 - 0.0 ) ) ) ) * -1.0 ) );
				float3 appendResult14_g141 = (float3(cos( temp_output_11_0_g141 ) , 0.0 , sin( temp_output_11_0_g141 )));
				float3 worldToObj35_g141 = mul( GetWorldToObjectMatrix(), float4( appendResult14_g141, 1 ) ).xyz;
				float3 worldToObj36_g141 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult34_g141 = normalize( (( worldToObj35_g141 - worldToObj36_g141 )).xyz );
				float3 MB_RotationAxis246 = normalizeResult34_g141;
				float3 RotationAxis56_g143 = MB_RotationAxis246;
				float MB_Amplitude207 = _MBAmplitude;
				float MB_AmplitudeOffset218 = _MBAmplitudeOffset;
				float2 StaticNoileTilling28_g135 = (temp_output_24_0_g135).xy;
				float4 StaticNoise202 = tex2Dlod( _NoiseTexture, float4( ( UVs27_g135 * StaticNoileTilling28_g135 ), 0, 0.0) );
				float4 StaticWorldNoise31_g142 = StaticNoise202;
				float3 objToWorld52_g142 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float MB_Frequency215 = _MBFrequency;
				float MB_FrequencyOffset209 = _MBFrequencyOffset;
				float DB_PhaseShift194 = input.ase_color.a;
				float MB_Phase208 = _MBPhase;
				float MB_DefaultBending206 = _MBDefaultBending;
				float MB_MaxHeight211 = _MBMaxHeight;
				float MB_RotationAngle245 = radians( ( ( ( ( MB_Amplitude207 + ( MB_AmplitudeOffset218 * (StaticWorldNoise31_g142).x ) ) * sin( ( ( ( objToWorld52_g142.x + objToWorld52_g142.z ) + ( ( ( _TimeParameters.x ) * ( MB_Frequency215 + ( MB_FrequencyOffset209 * (StaticWorldNoise31_g142).x ) ) ) + ( ( 2.0 * PI ) * DB_PhaseShift194 ) ) ) * MB_Phase208 ) ) ) + MB_DefaultBending206 ) * ( input.positionOS.xyz.y / MB_MaxHeight211 ) ) );
				float RotationAngle54_g143 = MB_RotationAngle245;
				float3 PivotPoint60_g143 = LocalPivot154;
				float3 break62_g143 = PivotPoint60_g143;
				float3 appendResult45_g143 = (float3(break62_g143.x , input.positionOS.xyz.y , break62_g143.z));
				float3 rotatedValue30_g143 = RotateAroundAxis( appendResult45_g143, input.positionOS.xyz, RotationAxis56_g143, RotationAngle54_g143 );
				float DB_HorizontalAmplitude189 = _DBHorizontalAmplitude;
				float DB_HorizontalFrequency193 = _DBHorizontalFrequency;
				float Frequency41_g136 = DB_HorizontalFrequency193;
				float3 objToWorld53_g136 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float DB_HorizontalPhase187 = _DBHorizontalPhase;
				float3 PivotPoint49_g136 = LocalPivot154;
				float3 break52_g136 = PivotPoint49_g136;
				float3 appendResult20_g136 = (float3(break52_g136.x , input.positionOS.xyz.y , break52_g136.z));
				float DB_HorizontalMaxRadius192 = _DBHorizontalMaxRadius;
				float3 rotatedValue33_g136 = RotateAroundAxis( PivotPoint49_g136, input.positionOS.xyz, float3( 0, 1, 0 ), radians( ( ( DB_HorizontalAmplitude189 * sin( ( ( ( ( _TimeParameters.x ) * Frequency41_g136 ) - ( ( 2.0 * PI ) * ( 1.0 - DB_PhaseShift194 ) ) ) + ( ( ( objToWorld53_g136.x + objToWorld53_g136.z ) + ( ( _TimeParameters.x ) * Frequency41_g136 ) ) * DB_HorizontalPhase187 ) ) ) ) * ( distance( input.positionOS.xyz , appendResult20_g136 ) / DB_HorizontalMaxRadius192 ) ) ) );
				#ifdef _ENABLEHORIZONTALBENDING_ON
				float3 staticSwitch242 = ( ( rotatedValue33_g136 - input.positionOS.xyz ) * 1.0 );
				#else
				float3 staticSwitch242 = float3( 0, 0, 0 );
				#endif
				float3 DB_VertexOffset248 = staticSwitch242;
				float3 rotatedValue34_g143 = RotateAroundAxis( PivotPoint60_g143, ( rotatedValue30_g143 + DB_VertexOffset248 ), RotationAxis56_g143, RotationAngle54_g143 );
				float3 temp_output_265_0 = ( ( rotatedValue34_g143 - input.positionOS.xyz ) * step( 0.01 , input.positionOS.xyz.y ) );
				float3 MainBending89_g144 = temp_output_265_0;
				float3 appendResult15_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld98_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult15_g144, 1 ) ).xyz;
				float3 objToWorld102_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 break20_g144 = ( objToWorld98_g144 - objToWorld102_g144 );
				float3 appendResult24_g144 = (float3(-break20_g144.z , 0.0 , break20_g144.x));
				float3 appendResult3_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld100_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult3_g144, 1 ) ).xyz;
				float3 objToWorld106_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 temp_output_107_0_g144 = ( objToWorld100_g144 - objToWorld106_g144 );
				float3 break108_g144 = temp_output_107_0_g144;
				float3 lerpResult84_g144 = lerp( float3( 0, 1, 0 ) , temp_output_107_0_g144 , step( 0.001 , ( abs( break108_g144.x ) + abs( break108_g144.z ) ) ));
				float3 normalizeResult7_g144 = normalize( lerpResult84_g144 );
				float dotResult9_g144 = dot( normalizeResult7_g144 , float3( 0, 1, 0 ) );
				float temp_output_12_0_g144 = acos( dotResult9_g144 );
				float NaNPrevention21_g144 = step( 0.01 , abs( ( temp_output_12_0_g144 * ( 180.0 / PI ) ) ) );
				float3 lerpResult26_g144 = lerp( float3( 1, 0, 0 ) , appendResult24_g144 , NaNPrevention21_g144);
				float3 worldToObj99_g144 = mul( GetWorldToObjectMatrix(), float4( lerpResult26_g144, 1 ) ).xyz;
				float3 worldToObj105_g144 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult49_g144 = normalize( ( worldToObj99_g144 - worldToObj105_g144 ) );
				float3 RotationAxis30_g144 = normalizeResult49_g144;
				float SlopeCorrectionOffset269 = _SlopeCorrectionOffset;
				float SlopeCorrectionMagnitude268 = _SlopeCorrectionMagnitude;
				float RotationAngle29_g144 = ( saturate( (  (0.0 + ( (StaticNoise202).x - 0.0 ) * ( SlopeCorrectionOffset269 - 0.0 ) / ( 1.0 - 0.0 ) ) + SlopeCorrectionMagnitude268 ) ) * temp_output_12_0_g144 );
				float3 rotatedValue35_g144 = RotateAroundAxis( LocalPivot154, ( input.positionOS.xyz + MainBending89_g144 ), RotationAxis30_g144, RotationAngle29_g144 );
				float3 lerpResult52_g144 = lerp( MainBending89_g144 , ( rotatedValue35_g144 - input.positionOS.xyz ) , NaNPrevention21_g144);
				#ifdef _ENABLESLOPECORRECTION_ON
				float3 staticSwitch282 = lerpResult52_g144;
				#else
				float3 staticSwitch282 = temp_output_265_0;
				#endif
				float3 LocalVertexOffset285 = staticSwitch282;
				
				output.ase_texcoord1.xy = input.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord1.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = LocalVertexOffset285;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				output.ase_texcoord = input.ase_texcoord;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag( PackedVaryings input
				#if defined( ASE_DEPTH_WRITE_ON )
				,out float outputDepth : ASE_SV_DEPTH
				#endif
				 ) : SV_Target
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;

				float2 uv_MainTex253 = input.ase_texcoord1.xy;
				float4 tex2DNode253 = tex2D( _MainTex, uv_MainTex253 );
				float2 uv_StemTexture260 = input.ase_texcoord1.xy;
				float4 tex2DNode260 = tex2D( _StemTexture, uv_StemTexture260 );
				float TextureMask250 = step( 1.5 , input.ase_texcoord1.xy.x );
				float lerpResult280 = lerp( tex2DNode253.a , tex2DNode260.a , TextureMask250);
				float Opacity283 = lerpResult280;
				

				surfaceDescription.Alpha = Opacity283;
				#if defined( _ALPHATEST_ON )
					surfaceDescription.AlphaClipThreshold = _AlphaCutoff;
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				return half4( _ObjectId, _PassValue, 1.0, 1.0 );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ScenePickingPass"
			Tags { "LightMode"="Picking" }

			AlphaToMask Off

			HLSLPROGRAM

			#define ASE_GEOMETRY
			#define _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define ASE_VERSION 19908
			#define ASE_SRP_VERSION 170004


			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

		    #define SCENEPICKINGPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _ENABLESLOPECORRECTION_ON
			#pragma shader_feature_local _ENABLEHORIZONTALBENDING_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _NoiseTextureTilling;
			float4 _FlowerColor2;
			float4 _FlowerColor1;
			float4 _StemColor;
			float2 _NoisePannerSpeed;
			float _MBWindDir;
			float _ColorBlendEnd;
			float _ColorBlendStart;
			float _SlopeCorrectionMagnitude;
			float _SlopeCorrectionOffset;
			float _DBHorizontalMaxRadius;
			float _DBHorizontalPhase;
			float _DBHorizontalFrequency;
			float _MBMaxHeight;
			float _MBDefaultBending;
			float _MBPhase;
			float _MBFrequencyOffset;
			float _MBFrequency;
			float _MBAmplitudeOffset;
			float _MBAmplitude;
			float _MBWindDirOffset;
			float _MBWindDirBlend;
			float _DBHorizontalAmplitude;
			float _AlphaCutoff;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float MBGlobalWindDir;
			sampler2D _NoiseTexture;
			sampler2D _MainTex;
			sampler2D _StemTexture;


			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float lerpResult181 = lerp( _MBWindDir , MBGlobalWindDir , _MBWindDirBlend);
				float MB_WindDirection205 = lerpResult181;
				float MB_WindDirectionOffset204 = _MBWindDirOffset;
				float2 texCoord152 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult153 = (float3(texCoord152.x , 0.0 , texCoord152.y));
				float3 LocalPivot154 = -appendResult153;
				float3 objToWorld11_g134 = mul( GetObjectToWorldMatrix(), float4( LocalPivot154, 1 ) ).xyz;
				float2 appendResult10_g134 = (float2(objToWorld11_g134.x , objToWorld11_g134.z));
				float2 UVs27_g135 = appendResult10_g134;
				float4 temp_output_24_0_g135 = _NoiseTextureTilling;
				float2 AnimatedNoiseTilling29_g135 = (temp_output_24_0_g135).zw;
				float2 panner7_g135 = ( 0.1 * _Time.y * _NoisePannerSpeed + float2( 0,0 ));
				float4 AnimatedNoise216 = tex2Dlod( _NoiseTexture, float4( ( ( UVs27_g135 * AnimatedNoiseTilling29_g135 ) + panner7_g135 ), 0, 0.0) );
				float temp_output_11_0_g141 = radians( ( ( MB_WindDirection205 + ( MB_WindDirectionOffset204 *  (-1.0 + ( (AnimatedNoise216).x - 0.0 ) * ( 1.0 - -1.0 ) / ( 1.0 - 0.0 ) ) ) ) * -1.0 ) );
				float3 appendResult14_g141 = (float3(cos( temp_output_11_0_g141 ) , 0.0 , sin( temp_output_11_0_g141 )));
				float3 worldToObj35_g141 = mul( GetWorldToObjectMatrix(), float4( appendResult14_g141, 1 ) ).xyz;
				float3 worldToObj36_g141 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult34_g141 = normalize( (( worldToObj35_g141 - worldToObj36_g141 )).xyz );
				float3 MB_RotationAxis246 = normalizeResult34_g141;
				float3 RotationAxis56_g143 = MB_RotationAxis246;
				float MB_Amplitude207 = _MBAmplitude;
				float MB_AmplitudeOffset218 = _MBAmplitudeOffset;
				float2 StaticNoileTilling28_g135 = (temp_output_24_0_g135).xy;
				float4 StaticNoise202 = tex2Dlod( _NoiseTexture, float4( ( UVs27_g135 * StaticNoileTilling28_g135 ), 0, 0.0) );
				float4 StaticWorldNoise31_g142 = StaticNoise202;
				float3 objToWorld52_g142 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float MB_Frequency215 = _MBFrequency;
				float MB_FrequencyOffset209 = _MBFrequencyOffset;
				float DB_PhaseShift194 = input.ase_color.a;
				float MB_Phase208 = _MBPhase;
				float MB_DefaultBending206 = _MBDefaultBending;
				float MB_MaxHeight211 = _MBMaxHeight;
				float MB_RotationAngle245 = radians( ( ( ( ( MB_Amplitude207 + ( MB_AmplitudeOffset218 * (StaticWorldNoise31_g142).x ) ) * sin( ( ( ( objToWorld52_g142.x + objToWorld52_g142.z ) + ( ( ( _TimeParameters.x ) * ( MB_Frequency215 + ( MB_FrequencyOffset209 * (StaticWorldNoise31_g142).x ) ) ) + ( ( 2.0 * PI ) * DB_PhaseShift194 ) ) ) * MB_Phase208 ) ) ) + MB_DefaultBending206 ) * ( input.positionOS.xyz.y / MB_MaxHeight211 ) ) );
				float RotationAngle54_g143 = MB_RotationAngle245;
				float3 PivotPoint60_g143 = LocalPivot154;
				float3 break62_g143 = PivotPoint60_g143;
				float3 appendResult45_g143 = (float3(break62_g143.x , input.positionOS.xyz.y , break62_g143.z));
				float3 rotatedValue30_g143 = RotateAroundAxis( appendResult45_g143, input.positionOS.xyz, RotationAxis56_g143, RotationAngle54_g143 );
				float DB_HorizontalAmplitude189 = _DBHorizontalAmplitude;
				float DB_HorizontalFrequency193 = _DBHorizontalFrequency;
				float Frequency41_g136 = DB_HorizontalFrequency193;
				float3 objToWorld53_g136 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float DB_HorizontalPhase187 = _DBHorizontalPhase;
				float3 PivotPoint49_g136 = LocalPivot154;
				float3 break52_g136 = PivotPoint49_g136;
				float3 appendResult20_g136 = (float3(break52_g136.x , input.positionOS.xyz.y , break52_g136.z));
				float DB_HorizontalMaxRadius192 = _DBHorizontalMaxRadius;
				float3 rotatedValue33_g136 = RotateAroundAxis( PivotPoint49_g136, input.positionOS.xyz, float3( 0, 1, 0 ), radians( ( ( DB_HorizontalAmplitude189 * sin( ( ( ( ( _TimeParameters.x ) * Frequency41_g136 ) - ( ( 2.0 * PI ) * ( 1.0 - DB_PhaseShift194 ) ) ) + ( ( ( objToWorld53_g136.x + objToWorld53_g136.z ) + ( ( _TimeParameters.x ) * Frequency41_g136 ) ) * DB_HorizontalPhase187 ) ) ) ) * ( distance( input.positionOS.xyz , appendResult20_g136 ) / DB_HorizontalMaxRadius192 ) ) ) );
				#ifdef _ENABLEHORIZONTALBENDING_ON
				float3 staticSwitch242 = ( ( rotatedValue33_g136 - input.positionOS.xyz ) * 1.0 );
				#else
				float3 staticSwitch242 = float3( 0, 0, 0 );
				#endif
				float3 DB_VertexOffset248 = staticSwitch242;
				float3 rotatedValue34_g143 = RotateAroundAxis( PivotPoint60_g143, ( rotatedValue30_g143 + DB_VertexOffset248 ), RotationAxis56_g143, RotationAngle54_g143 );
				float3 temp_output_265_0 = ( ( rotatedValue34_g143 - input.positionOS.xyz ) * step( 0.01 , input.positionOS.xyz.y ) );
				float3 MainBending89_g144 = temp_output_265_0;
				float3 appendResult15_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld98_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult15_g144, 1 ) ).xyz;
				float3 objToWorld102_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 break20_g144 = ( objToWorld98_g144 - objToWorld102_g144 );
				float3 appendResult24_g144 = (float3(-break20_g144.z , 0.0 , break20_g144.x));
				float3 appendResult3_g144 = (float3(0.0 , 1.0 , 0.0));
				float3 objToWorld100_g144 = mul( GetObjectToWorldMatrix(), float4( appendResult3_g144, 1 ) ).xyz;
				float3 objToWorld106_g144 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 temp_output_107_0_g144 = ( objToWorld100_g144 - objToWorld106_g144 );
				float3 break108_g144 = temp_output_107_0_g144;
				float3 lerpResult84_g144 = lerp( float3( 0, 1, 0 ) , temp_output_107_0_g144 , step( 0.001 , ( abs( break108_g144.x ) + abs( break108_g144.z ) ) ));
				float3 normalizeResult7_g144 = normalize( lerpResult84_g144 );
				float dotResult9_g144 = dot( normalizeResult7_g144 , float3( 0, 1, 0 ) );
				float temp_output_12_0_g144 = acos( dotResult9_g144 );
				float NaNPrevention21_g144 = step( 0.01 , abs( ( temp_output_12_0_g144 * ( 180.0 / PI ) ) ) );
				float3 lerpResult26_g144 = lerp( float3( 1, 0, 0 ) , appendResult24_g144 , NaNPrevention21_g144);
				float3 worldToObj99_g144 = mul( GetWorldToObjectMatrix(), float4( lerpResult26_g144, 1 ) ).xyz;
				float3 worldToObj105_g144 = mul( GetWorldToObjectMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult49_g144 = normalize( ( worldToObj99_g144 - worldToObj105_g144 ) );
				float3 RotationAxis30_g144 = normalizeResult49_g144;
				float SlopeCorrectionOffset269 = _SlopeCorrectionOffset;
				float SlopeCorrectionMagnitude268 = _SlopeCorrectionMagnitude;
				float RotationAngle29_g144 = ( saturate( (  (0.0 + ( (StaticNoise202).x - 0.0 ) * ( SlopeCorrectionOffset269 - 0.0 ) / ( 1.0 - 0.0 ) ) + SlopeCorrectionMagnitude268 ) ) * temp_output_12_0_g144 );
				float3 rotatedValue35_g144 = RotateAroundAxis( LocalPivot154, ( input.positionOS.xyz + MainBending89_g144 ), RotationAxis30_g144, RotationAngle29_g144 );
				float3 lerpResult52_g144 = lerp( MainBending89_g144 , ( rotatedValue35_g144 - input.positionOS.xyz ) , NaNPrevention21_g144);
				#ifdef _ENABLESLOPECORRECTION_ON
				float3 staticSwitch282 = lerpResult52_g144;
				#else
				float3 staticSwitch282 = temp_output_265_0;
				#endif
				float3 LocalVertexOffset285 = staticSwitch282;
				
				output.ase_texcoord1.xy = input.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord1.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = LocalVertexOffset285;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				output.ase_texcoord = input.ase_texcoord;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag( PackedVaryings input
				#if defined( ASE_DEPTH_WRITE_ON )
				,out float outputDepth : ASE_SV_DEPTH
				#endif
				 ) : SV_Target
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;

				float2 uv_MainTex253 = input.ase_texcoord1.xy;
				float4 tex2DNode253 = tex2D( _MainTex, uv_MainTex253 );
				float2 uv_StemTexture260 = input.ase_texcoord1.xy;
				float4 tex2DNode260 = tex2D( _StemTexture, uv_StemTexture260 );
				float TextureMask250 = step( 1.5 , input.ase_texcoord1.xy.x );
				float lerpResult280 = lerp( tex2DNode253.a , tex2DNode260.a , TextureMask250);
				float Opacity283 = lerpResult280;
				

				surfaceDescription.Alpha = Opacity283;
				#if defined( _ALPHATEST_ON )
					surfaceDescription.AlphaClipThreshold = _AlphaCutoff;
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				return unity_SelectionID;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "MotionVectors"
			Tags { "LightMode"="MotionVectors" }

			ColorMask RG

			HLSLPROGRAM

			#define ASE_GEOMETRY
			#define _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define ASE_VERSION 19908
			#define ASE_SRP_VERSION 170004


			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

            #define SHADERPASS SHADERPASS_MOTION_VECTORS

            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
			#endif

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MotionVectorsCommon.hlsl"

			

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 positionOld : TEXCOORD4;
				#if _ADD_PRECOMPUTED_VELOCITY
					float3 alembicMotionVector : TEXCOORD5;
				#endif
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 positionCSNoJitter : TEXCOORD0;
				float4 previousPositionCSNoJitter : TEXCOORD1;
				float3 positionWS : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _NoiseTextureTilling;
			float4 _FlowerColor2;
			float4 _FlowerColor1;
			float4 _StemColor;
			float2 _NoisePannerSpeed;
			float _MBWindDir;
			float _ColorBlendEnd;
			float _ColorBlendStart;
			float _SlopeCorrectionMagnitude;
			float _SlopeCorrectionOffset;
			float _DBHorizontalMaxRadius;
			float _DBHorizontalPhase;
			float _DBHorizontalFrequency;
			float _MBMaxHeight;
			float _MBDefaultBending;
			float _MBPhase;
			float _MBFrequencyOffset;
			float _MBFrequency;
			float _MBAmplitudeOffset;
			float _MBAmplitude;
			float _MBWindDirOffset;
			float _MBWindDirBlend;
			float _DBHorizontalAmplitude;
			float _AlphaCutoff;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			

			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				#if defined(APLICATION_SPACE_WARP_MOTION)
					output.positionCSNoJitter = mul(_NonJitteredViewProjMatrix, mul(UNITY_MATRIX_M, input.positionOS));
					output.positionCS = output.positionCSNoJitter;
				#else
					output.positionCS = vertexInput.positionCS;
					output.positionCSNoJitter = mul(_NonJitteredViewProjMatrix, mul(UNITY_MATRIX_M, input.positionOS));
				#endif

				float4 prevPos = ( unity_MotionVectorsParams.x == 1 ) ? float4( input.positionOld, 1 ) : input.positionOS;

				#if _ADD_PRECOMPUTED_VELOCITY
					prevPos = prevPos - float4(input.alembicMotionVector, 0);
				#endif

				output.previousPositionCSNoJitter = mul( _PrevViewProjMatrix, mul( UNITY_PREV_MATRIX_M, prevPos ) );

				output.positionWS = vertexInput.positionWS;

				// removed in ObjectMotionVectors.hlsl found in unity 6000.0.23 and higher
				//ApplyMotionVectorZBias( output.positionCS );
				return output;
			}

			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}

			half4 frag(	PackedVaryings input
				#if defined( ASE_DEPTH_WRITE_ON )
				,out float outputDepth : ASE_SV_DEPTH
				#endif
				 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;

				

				float Alpha = 1;
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#if defined(ASE_CHANGES_WORLD_POS)
					float3 positionOS = mul( GetWorldToObjectMatrix(),  float4( PositionWS, 1.0 ) ).xyz;
					float3 previousPositionWS = mul( GetPrevObjectToWorldMatrix(),  float4( positionOS, 1.0 ) ).xyz;
					input.positionCSNoJitter = mul( _NonJitteredViewProjMatrix, float4( PositionWS, 1.0 ) );
					input.previousPositionCSNoJitter = mul( _PrevViewProjMatrix, float4( previousPositionWS, 1.0 ) );
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				#if defined(APLICATION_SPACE_WARP_MOTION)
					return float4( CalcAswNdcMotionVectorFromCsPositions( input.positionCSNoJitter, input.previousPositionCSNoJitter ), 1 );
				#else
					return float4( CalcNdcMotionVectorFromCsPositions( input.positionCSNoJitter, input.previousPositionCSNoJitter ), 0, 0 );
				#endif
			}
			ENDHLSL
		}

	
	}
	
	CustomEditor "Nicrom.StylisedFlowerWithStem_MaterialInspector"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}

/*ASEBEGIN
Version=19908
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;151;-1287.664,899.8252;Inherit;False;901.0664;632.0813;;10;250;241;234;225;194;169;154;153;152;291;Vertex Colors and UVs Baked Data;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;164;-1918.332,-891.875;Inherit;False;1402.995;635.2527;;8;157;158;216;202;196;176;174;175;World Space Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;160;-3709.552,-642.1756;Inherit;False;1528.371;1283.004;;37;185;211;252;257;178;170;172;180;186;167;168;171;183;188;184;198;182;191;166;163;269;268;218;215;209;208;207;206;205;204;193;192;190;189;187;181;173;Material Properties;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;195;-1927.561,-0.6889648;Inherit;False;1409.019;646.176;;10;248;242;237;221;214;213;212;210;203;201;Detail Bending;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;200;-251.5986,-638.0399;Inherit;False;2939.909;1278.491;;33;285;282;279;275;276;270;273;265;263;254;256;258;2;3;0;5;4;246;245;243;240;226;230;223;227;229;224;228;220;222;236;233;238;Main Bending;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;156;770.3428,-2303.735;Inherit;False;1907.837;1399.909;;32;284;283;281;280;278;277;274;272;267;264;262;261;260;259;255;253;251;249;247;244;239;235;232;231;219;217;199;197;177;165;161;159;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;286;3077.092,-1084.603;Inherit;False;762.4954;633.0168;;6;290;288;289;146;1;287;Master Node;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;152;-1258.882,1372.079;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;153;-1002.553,1379.543;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;291;-796.6077,1382.413;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;154;-592.5531,1371.543;Inherit;False;LocalPivot;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;157;-1832.84,-851.1949;Inherit;False;154;LocalPivot;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;171;-3663.456,180.4723;Float;False;Property;_MBWindDir;MB Wind Dir;14;0;Create;True;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;175;-1565.223,-388.1399;Float;False;Property;_NoisePannerSpeed;Noise Panner Speed;28;0;Create;True;0;0;0;False;0;False;0.05,0.03;0.08,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;158;-1594.552,-845.6038;Inherit;False;WorldSpaceUVs - NHP;-1;;134;88a2e8a391a04e241878bdb87d9283a3;0;1;6;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;170;-2883.542,-361.7005;Float;False;Property;_DBHorizontalPhase;DB Horizontal Phase;21;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;176;-1587.583,-761.397;Inherit;True;Property;_NoiseTexture;Noise Texture;26;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;f55a7ba0496960f42a83ee7d64320fac;512fa11ad89d84543ad8d6c8d9cb6743;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;180;-2884.542,-554.7006;Float;False;Property;_DBHorizontalAmplitude;DB Horizontal Amplitude;19;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;178;-2885.542,-265.7005;Float;False;Property;_DBHorizontalMaxRadius;DB Horizontal Max Radius;22;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;168;-3660.362,270.9203;Inherit;False;Global;MBGlobalWindDir;MB Global Wind Dir;28;1;[HideInInspector];Create;True;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;172;-2885.542,-456.7006;Float;False;Property;_DBHorizontalFrequency;DB Horizontal Frequency;20;0;Create;True;0;0;0;False;0;False;1.16;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;167;-3662.362,358.9204;Inherit;False;Property;_MBWindDirBlend;MB Wind Dir Blend;16;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;174;-1649.223,-560.1409;Inherit;False;Property;_NoiseTextureTilling;Noise Tilling - Static (XY), Animated (ZW);27;0;Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;169;-1247.87,962.394;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;188;-3664.758,-12.26251;Inherit;False;Property;_MBFrequencyOffset;MB Frequency Offset;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;181;-3348.889,250.0605;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;187;-2498.543,-360.7005;Inherit;False;DB_HorizontalPhase;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;196;-1268.859,-631.2019;Inherit;False;WorldSpaceNoise - NHP;-1;;135;af5fa9ff24e18344ebcc05b64d296c57;0;4;22;FLOAT2;0,0;False;20;SAMPLER2D;;False;24;FLOAT4;1,1,1,1;False;19;FLOAT2;0.1,0.1;False;2;COLOR;0;COLOR;16
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;192;-2544.543,-269.7005;Inherit;False;DB_HorizontalMaxRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;186;-3658.745,453.6646;Float;False;Property;_MBWindDirOffset;MB Wind Dir Offset;15;0;Create;True;0;0;0;False;0;False;20;0;0;180;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;184;-3666.854,-106.3965;Float;False;Property;_MBFrequency;MB Frequency;11;0;Create;True;0;0;0;False;0;False;1.11;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;185;-3651.591,548.9056;Inherit;False;Property;_MBMaxHeight;MB Max Height;17;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;193;-2526.543,-454.7005;Float;False;DB_HorizontalFrequency;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;183;-3663.456,84.47235;Float;False;Property;_MBPhase;MB Phase;13;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;182;-3666.854,-298.3965;Float;False;Property;_MBAmplitude;MB Amplitude;9;0;Create;True;0;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;198;-3666.854,-202.3965;Float;False;Property;_MBAmplitudeOffset;MB Amplitude Offset;10;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;189;-2528.543,-554.7006;Float;False;DB_HorizontalAmplitude;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;191;-3666.854,-393.3957;Float;False;Property;_MBDefaultBending;MB Default Bending;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;194;-822.2731,1047.696;Float;False;DB_PhaseShift;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;211;-3132.295,545.9175;Inherit;False;MB_MaxHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;215;-3148.279,-106.3965;Float;False;MB_Frequency;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;203;-1809.205,365.802;Inherit;False;194;DB_PhaseShift;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;207;-3140.279,-298.3965;Float;False;MB_Amplitude;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;214;-1863.747,201.7581;Inherit;False;193;DB_HorizontalFrequency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;201;-1862.747,126.7581;Inherit;False;189;DB_HorizontalAmplitude;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;210;-1864.032,445.3931;Inherit;False;192;DB_HorizontalMaxRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;216;-734.7421,-558.9988;Inherit;False;AnimatedNoise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;204;-3196.457,452.4725;Inherit;False;MB_WindDirectionOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;212;-1785.284,527.9121;Inherit;False;154;LocalPivot;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;213;-1837.205,280.802;Inherit;False;187;DB_HorizontalPhase;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;218;-3180.279,-202.3965;Inherit;False;MB_AmplitudeOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;209;-3182.283,-12.10461;Inherit;False;MB_FrequencyOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;208;-3144.881,84.47235;Inherit;False;MB_Phase;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;206;-3171.279,-394.3957;Float;False;MB_DefaultBending;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;202;-734.899,-676.604;Inherit;False;StaticNoise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;205;-3174.457,245.9235;Float;False;MB_WindDirection;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;222;-156.2717,466.2941;Inherit;False;211;MB_MaxHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;221;-1354.763,110.9111;Float;False;Constant;_Vector2;Vector 2;27;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;224;-186.2717,174.59;Inherit;False;209;MB_FrequencyOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;236;-175.6106,-579.5919;Inherit;False;205;MB_WindDirection;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;238;-153.8096,367.7421;Inherit;False;194;DB_PhaseShift;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;233;-214.6105,-479.5919;Inherit;False;204;MB_WindDirectionOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;220;-132.3437,554.121;Inherit;False;202;StaticNoise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;229;-179.6676,-213.879;Inherit;False;206;MB_DefaultBending;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;228;-150.3437,81.12103;Inherit;False;215;MB_Frequency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;226;-125.3437,275.121;Inherit;False;208;MB_Phase;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;237;-1454.824,269.3081;Inherit;False;HorizontalBending - NHP;-1;;136;0b16e2546645f904a949bfd32be36037;0;7;44;FLOAT;1;False;39;FLOAT;1;False;43;FLOAT;1;False;40;FLOAT;0;False;46;FLOAT;2;False;47;FLOAT3;0,0,0;False;45;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;230;-187.3437,-15.87898;Inherit;False;218;MB_AmplitudeOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;223;-156.6106,-384.5919;Inherit;False;216;AnimatedNoise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;227;-148.3437,-114.879;Inherit;False;207;MB_Amplitude;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;240;167.1175,-494.078;Inherit;False;RotationAxis - NHP;-1;;141;b90648f17dcc4bc449d46e8cf04564ff;0;3;20;FLOAT;0;False;19;FLOAT;0;False;18;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;242;-1125.49,189.8591;Float;False;Property;_EnableHorizontalBending;Enable Horizontal Bending;18;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;243;171.9655,88.38421;Inherit;False;RotationAngle - NHP;-1;;142;87b0b7c0fc8f1424db43b84d20c2e79b;0;9;36;FLOAT;0;False;35;FLOAT;0;False;34;FLOAT;1;False;28;FLOAT;1;False;47;FLOAT;0;False;29;FLOAT;1;False;46;FLOAT;0;False;42;FLOAT;0.1;False;27;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;234;-1224.665,1224.376;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;225;-1178.519,1142.415;Inherit;False;Constant;_Float2;Float 2;26;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;257;-2883.587,-154.0486;Inherit;False;Property;_SlopeCorrectionMagnitude;Slope Correction Magnitude;24;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;252;-2886.941,-54.81773;Inherit;False;Property;_SlopeCorrectionOffset;Slope Correction Offset;25;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;248;-760.0511,191.2861;Float;False;DB_VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;246;610.3895,-498.5919;Inherit;False;MB_RotationAxis;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;245;616.2504,85.51019;Float;False;MB_RotationAngle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;241;-991.8041,1182.579;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;269;-2515.094,-55.80873;Inherit;False;SlopeCorrectionOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;268;-2543.765,-154.2486;Inherit;False;SlopeCorrectionMagnitude;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;254;925.6454,-159.964;Inherit;False;154;LocalPivot;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;256;885.2123,-65.45984;Inherit;False;248;DB_VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;258;878.2224,-238.8929;Inherit;False;245;MB_RotationAngle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;263;889.2224,-342.8931;Inherit;False;246;MB_RotationAxis;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;250;-818.8302,1178.196;Float;False;TextureMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;273;1313.543,30.2462;Inherit;False;269;SlopeCorrectionOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;270;1386.453,221.1479;Inherit;False;154;LocalPivot;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;275;1375.543,127.2462;Inherit;False;202;StaticNoise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;276;1283.959,-59.62979;Inherit;False;268;SlopeCorrectionMagnitude;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;265;1188.758,-217.4599;Inherit;False;MainBending - NHP;-1;;143;01dba1f3bc33e4b4fa301d2180819576;0;4;55;FLOAT3;0,0,0;False;53;FLOAT;0;False;59;FLOAT3;0,0,0;False;58;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;253;809.4907,-1406.275;Inherit;True;Property;_MainTex;Flower Texture;5;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;262;912.8847,-1202.3;Inherit;False;250;TextureMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;260;815.3457,-1104.697;Inherit;True;Property;_StemTexture;Stem Texture;6;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;279;1652.059,-8.337809;Inherit;False;SlopeCorrection - NHP;-1;;144;af38de3ca0adf3c4ba9b6a3dd482959e;0;5;87;FLOAT3;0,0,0;False;42;FLOAT;1;False;92;FLOAT;0;False;93;FLOAT4;0,0,0,0;False;41;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;280;1254.885,-1097.3;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;282;2110.565,-223.3759;Float;False;Property;_EnableSlopeCorrection;Enable Slope Correction;23;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;283;1469.436,-1103.28;Float;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;285;2421.911,-223.559;Float;False;LocalVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;159;837.4587,-2227.985;Inherit;False;Constant;_Vector33;Vector 33;20;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TexCoordVertexDataNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;161;819.3827,-2099.573;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;163;-3659.829,-588.5316;Inherit;False;Property;_ColorBlendStart;Color Blend Start;2;0;Create;True;0;0;0;False;0;False;0.1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;165;1080.561,-2164.288;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;173;-3139.55,-589.3907;Inherit;False;ColorBlendStart;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;166;-3656.732,-487.4366;Inherit;False;Property;_ColorBlendEnd;Color Blend End;3;0;Create;True;0;0;0;False;0;False;0.15;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;177;1264.872,-2170.484;Inherit;False;DistanceToCenter;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;199;966.923,-1849.274;Inherit;False;173;ColorBlendStart;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;197;957.923,-1928.274;Inherit;False;177;DistanceToCenter;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;190;-3137.632,-488.1176;Inherit;False;ColorBlendEnd;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;219;1213.924,-1880.274;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;217;1160.025,-1771.953;Inherit;False;190;ColorBlendEnd;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;235;1405.924,-1832.274;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;232;1325.924,-1672.273;Inherit;False;173;ColorBlendStart;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;231;1293.924,-1592.273;Inherit;False;177;DistanceToCenter;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;244;1565.924,-1640.273;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;239;1549.924,-1832.274;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;251;1690.225,-2181.238;Inherit;False;Property;_FlowerColor1;Flower Color 1;0;0;Create;True;0;0;0;False;0;False;0.7843137,0.454902,0.1411765,1;0.5754717,0.3435538,0.1465824,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;247;1699.026,-2002.022;Inherit;False;Property;_FlowerColor2;Flower Color 2;1;0;Create;True;0;0;0;False;0;False;0.8980392,0.9529412,1,1;0.009433985,0.4014694,1,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;249;1741.923,-1736.273;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;259;1956.925,-1557.882;Inherit;False;250;TextureMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;255;2005.747,-2003.551;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;261;1937.498,-1748.176;Float;False;Property;_StemColor;Stem Color;4;0;Create;True;0;0;0;False;0;False;0.3960784,0.5647059,0.1019608,1;0.8301887,0.5461104,0.3015307,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;264;2271.69,-1795.789;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;267;1265.885,-1339.3;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;272;1474.801,-1342.797;Inherit;False;TextureColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;274;2464.233,-1802.258;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;278;1998.529,-1137.053;Inherit;False;274;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;277;1971.287,-1235.578;Inherit;False;272;TextureColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;281;2216.907,-1193.387;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;284;2381.509,-1197.241;Float;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;146;3306.635,-925.976;Inherit;False;Constant;_Float3;Float 3;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;287;3279.602,-1029.638;Inherit;False;284;Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;290;3174.414,-714.8832;Inherit;False;Property;_AlphaCutoff;Alpha Cutoff;7;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;288;3234.505,-602.9194;Inherit;False;285;LocalVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;289;3278.14,-819.8077;Inherit;False;283;Opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;1;3542.734,-913.4128;Float;False;True;-1;2;Nicrom.StylisedFlowerWithStem_MaterialInspector;0;15;Nicrom/NHP/ASE/Stylised Flower With Stem;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;21;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;14;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;False;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;51;Category;0;0;  Instanced Terrain Normals;1;0;Lighting Model;0;0;Workflow;1;0;Surface;0;0;  Keep Alpha;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;0;0;Alpha Clipping;1;0;  Use Shadow Threshold;0;0;Fragment Normal Space;0;0;Forward Only;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;1;0;Receive Shadows;1;0;Specular Highlights;1;0;Environment Reflections;1;0;Receive SSAO;1;0;Motion Vectors;1;0;  Add Precomputed Velocity;0;0;  XR Motion Vectors;0;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position;1;0;Debug Display;0;0;Clear Coat;0;0;0;12;False;True;True;True;True;True;True;True;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;14;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;0;3.060538,-913.4128;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;14;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;292;3542.734,-853.4128;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;14;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;False;True;1;LightMode=DepthNormals;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;293;3542.734,-853.4128;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;14;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;False;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;1;LightMode=UniversalGBuffer;False;True;10;d3d11;gles;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;294;3542.734,-853.4128;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;SceneSelectionPass;0;8;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;295;3542.734,-853.4128;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ScenePickingPass;0;9;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;296;3542.734,-813.4128;Float;False;False;-1;3;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;MotionVectors;0;10;MotionVectors;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;False;False;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=MotionVectors;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;297;3542.734,-813.4128;Float;False;False;-1;3;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;XRMotionVectors;0;11;XRMotionVectors;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;True;1;False;;255;False;;1;False;;7;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;1;LightMode=XRMotionVectors;False;False;0;;0;0;Standard;0;False;0
WireConnection;153;0;152;1
WireConnection;153;2;152;2
WireConnection;291;0;153;0
WireConnection;154;0;291;0
WireConnection;158;6;157;0
WireConnection;181;0;171;0
WireConnection;181;1;168;0
WireConnection;181;2;167;0
WireConnection;187;0;170;0
WireConnection;196;22;158;0
WireConnection;196;20;176;0
WireConnection;196;24;174;0
WireConnection;196;19;175;0
WireConnection;192;0;178;0
WireConnection;193;0;172;0
WireConnection;189;0;180;0
WireConnection;194;0;169;4
WireConnection;211;0;185;0
WireConnection;215;0;184;0
WireConnection;207;0;182;0
WireConnection;216;0;196;16
WireConnection;204;0;186;0
WireConnection;218;0;198;0
WireConnection;209;0;188;0
WireConnection;208;0;183;0
WireConnection;206;0;191;0
WireConnection;202;0;196;0
WireConnection;205;0;181;0
WireConnection;237;44;201;0
WireConnection;237;39;214;0
WireConnection;237;43;213;0
WireConnection;237;40;203;0
WireConnection;237;46;210;0
WireConnection;237;47;212;0
WireConnection;240;20;236;0
WireConnection;240;19;233;0
WireConnection;240;18;223;0
WireConnection;242;1;221;0
WireConnection;242;0;237;0
WireConnection;243;36;229;0
WireConnection;243;35;227;0
WireConnection;243;34;230;0
WireConnection;243;28;228;0
WireConnection;243;47;224;0
WireConnection;243;29;226;0
WireConnection;243;46;238;0
WireConnection;243;42;222;0
WireConnection;243;27;220;0
WireConnection;248;0;242;0
WireConnection;246;0;240;0
WireConnection;245;0;243;0
WireConnection;241;0;225;0
WireConnection;241;1;234;1
WireConnection;269;0;252;0
WireConnection;268;0;257;0
WireConnection;250;0;241;0
WireConnection;265;55;263;0
WireConnection;265;53;258;0
WireConnection;265;59;254;0
WireConnection;265;58;256;0
WireConnection;279;87;265;0
WireConnection;279;42;276;0
WireConnection;279;92;273;0
WireConnection;279;93;275;0
WireConnection;279;41;270;0
WireConnection;280;0;253;4
WireConnection;280;1;260;4
WireConnection;280;2;262;0
WireConnection;282;1;265;0
WireConnection;282;0;279;0
WireConnection;283;0;280;0
WireConnection;285;0;282;0
WireConnection;165;0;159;0
WireConnection;165;1;161;0
WireConnection;173;0;163;0
WireConnection;177;0;165;0
WireConnection;190;0;166;0
WireConnection;219;0;197;0
WireConnection;219;1;199;0
WireConnection;235;0;219;0
WireConnection;235;1;217;0
WireConnection;244;0;232;0
WireConnection;244;1;231;0
WireConnection;239;0;235;0
WireConnection;249;0;239;0
WireConnection;249;1;244;0
WireConnection;255;0;251;0
WireConnection;255;1;247;0
WireConnection;255;2;249;0
WireConnection;264;0;255;0
WireConnection;264;1;261;0
WireConnection;264;2;259;0
WireConnection;267;0;253;0
WireConnection;267;1;260;0
WireConnection;267;2;262;0
WireConnection;272;0;267;0
WireConnection;274;0;264;0
WireConnection;281;0;277;0
WireConnection;281;1;278;0
WireConnection;284;0;281;0
WireConnection;1;0;287;0
WireConnection;1;3;146;0
WireConnection;1;4;146;0
WireConnection;1;6;289;0
WireConnection;1;7;290;0
WireConnection;1;8;288;0
ASEEND*/
//CHKSM=E8F46665C6158C4B2AE84289D90DA07A8FC37606