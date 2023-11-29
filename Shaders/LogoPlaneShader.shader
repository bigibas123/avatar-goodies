Shader "Bigi/LogoPlane" {
	Properties {
		_MainTexArray ("Texture", 2DArray) = "black" {}
		_OtherTextureId ("CellNumber", Int) = 0
		_AL_General_Intensity("Audiolink Intensity",Range(0.0,1.0)) = 0.0
		_MinAmbient ("Minimum ambient intensity", Range(0.0,1.0)) = 0.01
	}
	SubShader {
		Blend SrcAlpha OneMinusSrcAlpha
		Tags {
			"RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "LightMode" = "ForwardBase" "VRCFallback"="Hidden"
		}

		CGINCLUDE
		#define GRID_SIZE 8
		#pragma vertex vert alpha
		#pragma fragment frag alpha
		#pragma multi_compile_instancing
		#pragma instancing_options assumeuniformscaling
		#pragma multi_compile_instancing
		#pragma multi_compile_fwdbase
		#pragma multi_compile_fwdbasealpha
		#pragma multi_compile_fog
		#pragma target 3.0

		#define MULTI_TEXTURE
		#define OTHER_BIGI_TEXTURES
		#include <UnityCG.cginc>
		uniform float _AL_General_Intensity;
		
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
			
			GET_SOUND_COLOR_CALL(soundSettings,sound)
			
			
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
			ENDCG
		}

		Pass {
			Name "TransparentForwardAddBack"
			Tags {
				"RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "LightMode" = "ForwardAdd" "VRCFallback"="Hidden"
			}
			Cull Front
			ZWrite Off
			ZTest LEqual
			Blend One One
			CGPROGRAM
			ENDCG
		}

		Pass {
			Name "TransparentForwardBaseFront"
			Cull Back
			ZWrite Off
			ZTest LEqual
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			ENDCG
		}

		
		Pass {
			Name "TransparentForwardAddFront"
			Tags {
				"RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "LightMode" = "ForwardAdd" "VRCFallback"="Hidden"
			}
			Cull Back
			ZWrite Off
			ZTest LEqual
			Blend One One
			CGPROGRAM
			ENDCG
		}

	}
}