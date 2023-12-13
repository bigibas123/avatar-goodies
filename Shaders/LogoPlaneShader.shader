Shader "Bigi/LogoPlane" {
	Properties {
		_MainTexArray ("Texture", 2DArray) = "black" {}
		_OtherTextureId ("CellNumber", Int) = 0
		_AL_General_Intensity("Audiolink Intensity",Range(0.0,1.0)) = 0.0
		_MinAmbient ("Minimum ambient intensity", Range(0.0,1.0)) = 0.01
	}
	CustomEditor "Characters.Common.Editor.Tools.BigiShaderEditor.BigiShaderEditor"
	SubShader {
		Blend SrcAlpha OneMinusSrcAlpha
		Tags {
			"RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "LightMode" = "ForwardBase" "VRCFallback"="Hidden"
		}

		CGINCLUDE
		#ifndef MULTI_TEXTURE
		#define MULTI_TEXTURE
		#endif

		#define OTHER_BIGI_TEXTURES
		#include <UnityCG.cginc>
		uniform float _AL_General_Intensity;
		#include "./Includes/BigiShaderParams.cginc"
		#include "./Includes/BigiShaderTextures.cginc"
		#include "./Includes/ToonVert.cginc"
		#include "./Includes/LightUtilsDefines.cginc"
		#include "./Includes/SoundUtilsDefines.cginc"


		void setLightVars()
		{
			_LightDiffuseness = 1.0;
			_AddLightIntensity = 1.0;
			_VertLightIntensity = 1.0;
		}

		v2f vert(appdata v)
		{
			setLightVars();
			return bigi_toon_vert(v);
		}

		fragOutput frag(v2f i)
		{
			setLightVars();
			fragOutput o;
			UNITY_INITIALIZE_OUTPUT(fragOutput, o);
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
			const fixed4 orig_color = GET_TEX_COLOR(i.uv);
			clip(orig_color.a - Epsilon);


			BIGI_GETLIGHT_NOAO(lighting);

			const fixed4 normalColor = orig_color * lighting;

			GET_SOUND_SETTINGS(soundSettings)

			soundSettings.AL_Hue_Weight = 0.0;

			soundSettings.AL_Theme_Weight = _AL_General_Intensity;
			soundSettings.AL_TC_BassReactive = 1.0;

			GET_SOUND_COLOR_CALL(soundSettings, sound)


			o.color = lerp(normalColor,fixed4(sound.rgb, normalColor.a), sound.a);
			//o.color = orig_color;
			UNITY_APPLY_FOG(i.fogCoord, o.color);
			return o;
		}
		ENDCG

		Pass {
			Name "TransparentForwardBaseBack"
			Cull Front
			ZWrite Off
			ZTest LEqual
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#ifndef LIL_APP_POSITION
			#include_with_pragmas "./Includes/Pragmas/ForwardBase.cginc"
			#else
			#include_with_pragmas "Assets/Characters/Common/Shaders/Includes/Pragmas/ForwardBase.cginc"
			#endif
			#pragma vertex vert alpha
			#pragma fragment frag alpha
			ENDCG
		}

		Pass {
			Name "TransparentForwardAddBack"
			Tags {
				"RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "LightMode" = "ForwardAdd"
			}
			Cull Front
			ZWrite Off
			ZTest LEqual
			Blend One One
			CGPROGRAM
			#ifndef LIL_APP_POSITION
			#include_with_pragmas "./Includes/Pragmas/ForwardAdd.cginc"
			#else
			#include_with_pragmas "Assets/Characters/Common/Shaders/Includes/Pragmas/ForwardAdd.cginc"
			#endif
			#pragma vertex vert alpha
			#pragma fragment frag alpha
			ENDCG
		}

		Pass {
			Name "TransparentForwardBaseFront"
			Cull Back
			ZWrite Off
			ZTest LEqual
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#ifndef LIL_APP_POSITION
			#include_with_pragmas "./Includes/Pragmas/ForwardBase.cginc"
			#else
			#include_with_pragmas "Assets/Characters/Common/Shaders/Includes/Pragmas/ForwardBase.cginc"
			#endif
			#pragma vertex vert alpha
			#pragma fragment frag alpha
			ENDCG
		}


		Pass {
			Name "TransparentForwardAddFront"
			Tags {
				"RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "LightMode" = "ForwardAdd"
			}
			Cull Back
			ZWrite Off
			ZTest LEqual
			Blend One One
			CGPROGRAM
			#ifndef LIL_APP_POSITION
			#include_with_pragmas "./Includes/Pragmas/ForwardAdd.cginc"
			#else
			#include_with_pragmas "Assets/Characters/Common/Shaders/Includes/Pragmas/ForwardAdd.cginc"
			#endif
			#pragma vertex vert alpha
			#pragma fragment frag alpha
			ENDCG
		}

		Pass {
			Name "META"
			Tags {
				"LightMode" = "Meta"
			}
			CGPROGRAM
			#ifndef LIL_APP_POSITION
			#include_with_pragmas "./Includes/Pragmas/Meta.cginc"
			#else
			#include_with_pragmas "Assets/Characters/Common/Shaders/Includes/Pragmas/Meta.cginc"
			#endif
			#pragma vertex vertm alpha
			#pragma fragment fragm alpha
			#include "UnityCG.cginc"
			#include "UnityMetaPass.cginc"
			#include "./Includes/BigiShaderTextures.cginc"
			#include "./Includes/BigiShaderParams.cginc"

			struct v2fm
			{
				UNITY_POSITION(pos);
				float2 uv : TEXCOORD0;
				float2 uvIllum : TEXCOORD1;
				#ifdef EDITOR_VISUALIZATION
                float2 vizUV : TEXCOORD2;
                float4 lightCoord : TEXCOORD3;
				#endif
				float4 staticTexturePos : TEXCOORD4;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			float4 _Illum_ST;

			v2fm vertm(appdata_full v)
			{
				v2fm o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST,
												unity_DynamicLightmapST);
				o.uv = DO_TRANSFORM(v.texcoord);
				o.uvIllum = TRANSFORM_TEX(v.texcoord, _Illum);
				#ifdef EDITOR_VISUALIZATION
                    o.vizUV = 0;
                    o.lightCoord = 0;
                    if (unity_VisualizationMode == EDITORVIZ_TEXTURE)
                        o.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, v.texcoord.xy, v.texcoord1.xy, v.texcoord2.xy, unity_EditorViz_Texture_ST);
                    else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK)
                    {
                        o.vizUV = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                        o.lightCoord = mul(unity_EditorViz_WorldToLight, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)));
                    }
				#endif
				o.staticTexturePos = ComputeScreenPos(o.pos);
				return o;
			}

			sampler2D _Illum;

			half4 fragm(v2fm i) : SV_Target
			{
				UnityMetaInput metaIN;
				UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
				const fixed4 orig_color = GET_TEX_COLOR(i.uv);
				clip(orig_color.a - Epsilon);
				const fixed4 normalColor = orig_color;

				GET_SOUND_SETTINGS(soundSettings)

				soundSettings.AL_Hue_Weight = 0.0;

				soundSettings.AL_Theme_Weight = _AL_General_Intensity;
				soundSettings.AL_TC_BassReactive = 1.0;

				GET_SOUND_COLOR_CALL(soundSettings, sound)


				metaIN.Albedo = normalColor.rgb * normalColor.a;
				metaIN.Emission = sound.rgb * sound.a * normalColor.a * 5.0;

				#if defined(EDITOR_VISUALIZATION)
                    metaIN.VizUV = i.vizUV;
                    metaIN.LightCoord = i.lightCoord;
				#endif

				return UnityMetaFragment(metaIN);
			}
			ENDCG
		}

	}
}