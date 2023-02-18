Shader "Bigi/FingerTrail" {
	Properties {
		_Brightness ("Brightness", Range(0.0,1.0)) = 0.001
		_Hue("NonALHue", Range(0.0,1.0)) = 0.0
	}

	Category {
		Tags {
			"Queue" = "Overlay" "IgnoreProjector"="True" "RenderType"="Transparent+2"
		}
		Blend SrcAlpha One
		ColorMask RGB
		Cull Off Lighting Off ZWrite Off

		SubShader {
			Pass {
				//ZTest Always
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				#pragma multi_compile_particles
				#pragma multi_compile_fog

				#include <UnityCG.cginc>
				#include "Includes/BigiSoundUtils.cginc"
				float _Brightness;
				float _Hue;

				struct appdata_t {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID };

				struct v2f {
					float4 pos : SV_POSITION;
					float4 worldPos: TEXCOORD0;
					fixed4 color : COLOR;
					UNITY_FOG_COORDS(1) UNITY_VERTEX_OUTPUT_STEREO };

				v2f vert(appdata_t v)
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					UNITY_TRANSFER_FOG(o, o.pos);
					return o;
				}

				half4 frag(v2f i) : SV_Target
				{
					half4 col;

					if (AudioLinkIsAvailable()) {
						const float soundTime = b_sound::GetTime();
						const half themeColorIndex = (((i.color.r + soundTime) * 3.0f) % 3.0f);
						const half4 c1 = b_sound::GetThemeColor(themeColorIndex);
						const half4 c2 = b_sound::GetThemeColor((themeColorIndex + 1) % 3);
						col = lerp(c1, c2, frac(themeColorIndex));
					} else { col = half4(HSVToRGB(half3(_Hue, 1.0, 1.0)), 1.0); }

					UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0));
					return half4(col.rgb * _Brightness, col.a);
				}
				ENDCG
			}
		}
	}
}