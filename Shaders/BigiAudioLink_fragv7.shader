Shader "Bigi/AudioLink_fragv7" {
	Properties {
		[MainTexture] _MainTex ("Texture", 2D) = "black" {}
		_Spacey ("Spacey Texture", 2D) = "black" {}
		_EmissionStrength ("Emission strength", Range(0.0,1.0)) = 1.0
		[NoScaleOffset] _Mask ("Mask", 2D) = "black" {}
		[NoScaleOffset] _AOMap ("Ambient occlusion map", 2D) = "white" {}
		_AudioIntensity ("AudioLink Intensity (0.5 in normal)", Range(0.0,1.0)) = 0.001
		_ColorChordIndex ("ColorChord Index (0=Old behaviour, 1-4 color chords) (0-4)", Int) = 0
		_DMXGroup ("DMX Group", Int) = 2
		_OutlineWidth ("Outline Width", Range(0.0,1.0)) = 0.5
		[MaterialToggle] _UseBassIntensity ("Use Lower Tone Intensity", Range(0.0,1.0) ) = 0.0
		_AddLightIntensity ("Additive lighting intensity", Range(0.0,1.0)) = 0.1
		_MinAmbient ("Minimum ambient intensity", Range(0.0,1.0)) = 0.005
		[Toggle] _Invisibility ("Invisibility", Int) = 0
		_ALSoundHue ("Audiolink Sound hue", Range (0.0,1.0)) = 0.0
	}
	SubShader {
		Blend SrcAlpha OneMinusSrcAlpha

		LOD 100

		Pass {
			Name "OpaqueForwardBase"
			Tags {
				"RenderType" = "Opaque" "Queue" = "Geometry" "VRCFallback"="ToonCutout" "LightMode" = "ForwardBase"
			}
			Cull Back
			ZWrite On
			ZTest LEqual
			Blend One OneMinusSrcAlpha
			Stencil {
				Ref 1
				Comp Always
				WriteMask 1
				Pass Replace
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma instancing_options assumeuniformscaling
			#pragma multi_compile_instancing
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fwdbasealpha
			#pragma multi_compile_lightpass
			#pragma multi_compile_shadowcollector
			#pragma multi_compile_fog
			#pragma target 3.0
			#include "./Includes/BigiShaderParams.cginc"
			#include "./Includes/ColorUtil.cginc"
			#include "./Includes/ToonVert.cginc"
			#include "./Includes/BigiSoundUtils.cginc"
			#include "./Includes/BigiLightUtils.cginc"

			struct BEffectsTracker {
				float totalWeight;
				fixed3 totalColor;
			};

			void doMixProperly(inout BEffectsTracker obj, in fixed3 color, in float weight, in float force)
			{
				obj.totalWeight += weight;
				obj.totalColor = lerp(obj.totalColor, color, (weight * force) / obj.totalWeight);
			}

			fragOutput frag(v2f i)
			{
				clip(-1 * _Invisibility);
				fixed4 orig_color = UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
				clip(orig_color.a - 1.0);
				fragOutput o;
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				UNITY_INITIALIZE_OUTPUT(fragOutput, o);
				BIGI_GETLIGHT_DEFAULT(lighting);

				BEffectsTracker mix;
				mix.totalWeight = 1.0;
				mix.totalColor = orig_color * lighting;
				//mix.totalColor = 0.0;

				fixed4 mask = UNITY_SAMPLE_TEX2D_SAMPLER(_Mask, _MainTex, i.uv);
				//Audiolink
				if (_AudioIntensity > Epsilon) {
					if (AudioLinkIsAvailable()) {
						const fixed4 soundColor = b_sound::GetSoundColor(_ColorChordIndex, _UseBassIntensity, _AudioIntensity, _ALSoundHue);
						doMixProperly(mix, soundColor, mask.b * soundColor.a * RGBToHSV(soundColor.rgb).z, 2.0);
					}
				} else {
					const b_sound::dmx_info dmxI = b_sound::GetDMXInfo(_DMXGroup);
					doMixProperly(mix, dmxI.ResultColor, dmxI.Intensity * mask.b, 2.0);
				}
				//"Emissions"
				{
					doMixProperly(mix, orig_color, saturate((mask.r * _EmissionStrength) - (mix.totalWeight - 1.0)), 2.0);
				}
				//Screenspace images
				{
					float2 tpos = TRANSFORM_TEX((i.staticTexturePos.xy / i.staticTexturePos.w), _Spacey);
					doMixProperly(mix,UNITY_SAMPLE_TEX2D(_Spacey, tpos), mask.g, 1.0);
				}

				o.color = half4(mix.totalColor, orig_color.a);
				UNITY_APPLY_FOG(i.fogCoord, o.color);
				return o;
			}
			ENDCG
		}

		Pass {
			Name "TransparentForwardBase"
			Tags {
				"RenderType" = "TransparentCutout" "Queue" = "AlphaTest" "LightMode" = "ForwardBase" "VRCFallback"="ToonCutout"
			}
			Stencil {
				Ref 1
				Comp Always
				WriteMask 1
				Pass Replace
			}
			Cull Back
			ZWrite Off
			ZTest LEqual
			//Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma instancing_options assumeuniformscaling
			#pragma multi_compile_instancing
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fwdbasealpha
			#pragma multi_compile_lightpass
			#pragma multi_compile_shadowcollector
			#pragma multi_compile_fog
			#pragma target 3.0
			#include "./Includes/ToonVert.cginc"
			#include "./Includes/BigiLightUtils.cginc"


			fragOutput frag(v2f i)
			{
				clip(-1 * _Invisibility);
				fixed4 orig_color = UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
				clip((-1.0 * (orig_color.a - 1.0)) - Epsilon);
				fragOutput o;
				UNITY_INITIALIZE_OUTPUT(fragOutput, o);
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				BIGI_GETLIGHT_DEFAULT(lighting);
				o.color = orig_color * lighting;
				UNITY_APPLY_FOG(i.fogCoord, o.color);
				return o;
			}
			ENDCG
		}


		Pass {
			Name "ForwardAdd"
			Tags {
				"LightMode" = "ForwardAdd" "Queue" = "TransparentCutout"
			}
			Cull Back
			ZWrite Off
			ZTest LEqual
			Blend One One
			Stencil {
				Ref 1
				ReadMask 1
				Comp Equal
			}
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma instancing_options assumeuniformscaling
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_lightpass
			#pragma multi_compile_shadowcollector
			#pragma multi_compile_fog
			#pragma multi_compile_instancing

			#include "./Includes/ToonVert.cginc"
			#include "./Includes/BigiLightUtils.cginc"

			fragOutput frag(v2f i)
			{
				clip(-1 * _Invisibility);
				clip(_AddLightIntensity - Epsilon);
				fixed4 orig_color = UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
				clip(orig_color.a - Epsilon);
				fragOutput o;
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				UNITY_INITIALIZE_OUTPUT(fragOutput, o);

				BIGI_GETLIGHT_DEFAULT(lighting);
				o.color = half4(lighting * _AddLightIntensity) * orig_color;
				//o.color = float4(1.0,1.0,1.0,1.0);
				UNITY_APPLY_FOG(i.fogCoord, o.color);
				return o;
			}
			ENDCG
		}


		Pass {
			Name "Outline"
			Tags {
				"RenderType" = "TransparentCutout" "Queue" = "Transparent+-1"
			}
			Cull Off
			ZWrite On
			ZTest LEqual
			Stencil {
				Ref 0
				ReadMask 7
				Comp GEqual
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma instancing_options assumeuniformscaling
			#pragma multi_compile_instancing
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fwdbasealpha
			#pragma multi_compile_lightpass
			#pragma multi_compile_shadowcollector
			#pragma multi_compile_fog
			#pragma target 3.0
			#include "./Includes/BigiShaderParams.cginc"
			#include "./Includes/BigiSoundUtils.cginc"


			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID };

			//intermediate
			struct v2f {
				UNITY_POSITION(pos); //float4 pos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID UNITY_VERTEX_OUTPUT_STEREO };

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f, o)
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				float3 offset = v.normal.xyz * (_OutlineWidth * 0.01);
				o.pos = UnityObjectToClipPos(v.vertex + offset);
				return o;
			}

			fragOutput frag(v2f i)
			{
				clip((-1 * _Invisibility) + _OutlineWidth - Epsilon);
				fragOutput o;
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				UNITY_INITIALIZE_OUTPUT(fragOutput, o);
				if (_AudioIntensity > Epsilon) {
					if (AudioLinkIsAvailable()) {
						o.color = b_sound::GetSoundColor(_ColorChordIndex, _UseBassIntensity, _AudioIntensity, _ALSoundHue);
					} else { discard; }
				} else {
					clip(_DMXGroup - 1);
					o.color = half4(b_sound::GetDMXInfo(_DMXGroup).ResultColor, 1.0);
				}
				return o;
			}
			ENDCG

		}

		//UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

		Pass {
			Name "ShadowPass"
			Tags {
				"LightMode"="ShadowCaster"
			}
			Cull Off
			ZWrite On
			ZTest LEqual
			Stencil {
				Comp Always
				Pass IncrSat
			}
			CGPROGRAM
			#pragma vertex vert alpha
			#pragma fragment frag alpha
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing
			#pragma multi_compile_lightpass
			#pragma instancing_options assumeuniformscaling
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fwdbasealpha
			#pragma multi_compile_lightpass
			#pragma multi_compile_fog
			#pragma target 3.0
			#include "UnityCG.cginc"
			uniform int _Invisibility;

			struct v2f {
				V2F_SHADOW_CASTER;
				UNITY_VERTEX_INPUT_INSTANCE_ID UNITY_VERTEX_OUTPUT_STEREO
				//float4 uv : TEXCOORD0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f, o)
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				//o.uv = v.texcoord;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				clip(-1 * _Invisibility);
				UNITY_SETUP_INSTANCE_ID(i) UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i) SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
	}
}