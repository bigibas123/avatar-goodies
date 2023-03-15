Shader "Bigi/ALTest" {
	Properties {
		[MainTexture] _MainTex ("Texture", 2D) = "black"
	}
	SubShader {
		Blend SrcAlpha OneMinusSrcAlpha
		Tags {
			"PreviewType" = "Plane"
		}

		LOD 100

		Pass {
			Name "ForwardBase"
			Tags {
				"RenderType" = "TransparentCutout" "Queue" = "Geometry" "VRCFallback"="None" "LightMode" = "ForwardBase"
			}
			Cull Off
			ZWrite On
			ZTest LEqual
			Blend One OneMinusSrcAlpha
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
			#define EXTERNAL_AUDIOLINK_ON
			#include "./Includes/BigiShaderParams.cginc"
			#include "./Includes/ToonVert.cginc"
			#include "./Includes/LightUtilsDefines.cginc"
			#include "./Includes/SoundUtilsDefines.cginc"
			#include "./Includes/BigiEffects.cginc"
			#include "Packages/com.llealloo.audiolink/Runtime/Shaders/SmoothPixelFont.cginc"

			fragOutput frag(v2f i)
			{
				fragOutput o;
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				UNITY_INITIALIZE_OUTPUT(fragOutput, o);
				i.uv.y = (1.0f - (i.uv.y));
				float2 squarepos;
				squarepos.x = i.uv.x % 0.5f * 2.0f;
				squarepos.y = i.uv.y % 0.5f * 2.0f;

				if (i.uv.x < 0.5 && i.uv.y < 0.5) {
					float2 gridlocf = squarepos * float2(18, 6);
					uint2 gridloc = gridlocf;

					float2 softness_uv = gridlocf * float2(4, 6);
					float softness = 4. / (pow(length(float2(ddx(softness_uv.x), ddy(softness_uv.y))), 0.5)) - 1.;

					float2 charUV = float2(4, 6) - fmod(gridlocf, 1.0) * float2(4.0, 6.0);
					if (gridloc.y < 1) {
						int character = AudioLinkGetMasterNameChar(gridloc.x);

						o.color = PrintChar(character, charUV, softness, 0);
					} else if (gridloc.y < 5) {
						float time = AudioLinkGetChronoTime(0, gridloc.y - 1);
						o.color = PrintNumberOnLine(time, charUV, softness, gridloc.x, 13, 4, false, 0);
					}
					o.color.a = 1.0;
				} else if (i.uv.x > 0.5 && i.uv.y < 0.5) {
					float2 gridlocf = squarepos * float2(4, 32);
					uint band = gridlocf.x;
					gridlocf.y = 31.0 - (gridlocf.y);
					float sound;
					if (gridlocf.y < 0.0) { sound = 1.0; } else { sound = AudioLinkLerp(ALPASS_AUDIOLINK + (gridlocf.yx)).r; }

					float3 bandColor = band < 1 ? float3(1, 0, 0) : band < 2 ? float3(1, 1, 0) : band < 3 ? float3(0, 1, 0) : float3(0, 0, 1);
					o.color = float4(bandColor * sound, 1.0);
				} else {
					squarepos.y -= 0.5;
					half3 al = AudioLinkLerp(ALPASS_AUTOCORRELATOR + float2((abs(1. - i.uv.x * 2.)) * AUDIOLINK_WIDTH, 0)).rgb;
					o.color = half4(
						smoothstep(0.02, 0.0, abs(((al.r * 0.25) - squarepos.y))),
						smoothstep(0.02, 0.0, abs(((al.g * 0.25) - squarepos.y))),
						smoothstep(0.02, 0.0, abs(((al.b * 0.25) - squarepos.y))),
						1.0
					);
				}
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
			#include "./Includes/LightUtilsDefines.cginc"

			fragOutput frag(v2f i)
			{
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