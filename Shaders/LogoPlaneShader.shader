Shader "Bigi/LogoPlane" {
	Properties {
		[MainTexture] _MainTex ("Texture", 2D) = "black" {}
		_VDivs ("Vertical Cells", Int) = 2
		_HDivs ("Horizontal Cells", Int) = 2
		_CellNumber ("CellNumber", Int) = 0
		_AudioIntensity ("AudioLink Intensity (0.5 in normal)", Range(0.0,1.0)) = 0.5
		_DMXGroup ("DMX Group", Int) = 2
		_ColorChordIndex ("ColorChord Index (0=Old behaviour, 1-4 color chords) (0-4)", Int) = 1
		[MaterialToggle] _UseBassIntensity ("Use Lower Tone Intensity", Range(0.0,1.0) ) = 0.0
	}
	SubShader {
		Blend SrcAlpha OneMinusSrcAlpha
		Tags {
			"RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "LightMode" = "ForwardBase" "VRCFallback"="Hidden"
		}
		
		CGINCLUDE
			#include "./Includes/PassDefault.cginc"

			UNITY_DECLARE_TEX2D(_MainTex);
			float4 _MainTex_ST;

			uniform uint _VDivs;
			uniform uint _HDivs;
			uniform uint _CellNumber;

			#include "./Includes/BigiLightUtils.cginc"
			#include "./Includes/BigiSoundUtils.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
		
			//intermediate
			struct v2f {
				UNITY_POSITION(pos); //float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				half2 uv : TEXCOORD0; //texture coordinates
				LIGHTING_COORDS(1, 2) UNITY_FOG_COORDS(3) //put for info into TEXCOORD2
				UNITY_VERTEX_OUTPUT_STEREO
			};

			struct fragOutput {
				fixed4 color : SV_Target;
			};

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o)
				o.pos = UnityObjectToClipPos(v.vertex);

				const float2 cell_size = float2(1.0 / _HDivs, 1.0 / _VDivs);
				const uint2 coords = uint2(_CellNumber % _HDivs, floor(_CellNumber / _HDivs));
				const half2 start_coord = cell_size * coords;
				const half2 offset = TRANSFORM_TEX(v.texcoord, _MainTex) * cell_size;
				o.uv = start_coord + offset;
				o.normal = v.normal;
				UNITY_TRANSFER_LIGHTING(o, o.pos);
				UNITY_TRANSFER_FOG(o, o.pos);
				return o;
			}

			uniform half _AudioIntensity;
			uniform int _ColorChordIndex;
			uniform half _UseBassIntensity;
			uniform int _DMXGroup;

			fragOutput frag(v2f i)
			{
				fragOutput o;
				UNITY_INITIALIZE_OUTPUT(fragOutput, o);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
				const fixed4 orig_color = UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
				clip(orig_color.a - Epsilon);
				half4 sound;
				half soundIntensity;
				if (_AudioIntensity > Epsilon) {
					sound = b_sound::GetSoundColor(_ColorChordIndex, _UseBassIntensity, _AudioIntensity);
					soundIntensity = clamp(RGBToHSV(sound).z, 0.0, 1.0);
				} else {
					const b_sound::dmx_info dmxI = b_sound::GetDMXInfo(_DMXGroup);
					sound = half4(dmxI.ResultColor, 1.0) * dmxI.Intensity;
					soundIntensity = dmxI.Intensity;
				}
				const fixed4 normalColor = orig_color * b_light::GetLighting(i.normal, _WorldSpaceLightPos0, _LightColor0, LIGHT_ATTENUATION(i));
				const half intensity = clamp(soundIntensity, 0.0, 1.0);
				o.color = lerp(normalColor,fixed4(sound.rgb, normalColor.a), clamp(b_sound::Scale(intensity, 1.0), 0.0, 1.0));
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
			#pragma vertex vert alpha
			#pragma fragment frag alpha
			#pragma multi_compile_instancing
			#pragma instancing_options assumeuniformscaling
			#pragma multi_compile_instancing
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fwdbasealpha
			#pragma multi_compile_lightpass
			#pragma multi_compile_shadowcollector
			#pragma multi_compile_fog
			#pragma target 3.0
			ENDCG
		}
		Pass {
			Name "TransparentForwardBaseFront"
			Cull Back
			ZWrite Off
			ZTest LEqual
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert alpha
			#pragma fragment frag alpha
			#pragma multi_compile_instancing
			#pragma instancing_options assumeuniformscaling
			#pragma multi_compile_instancing
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fwdbasealpha
			#pragma multi_compile_lightpass
			#pragma multi_compile_shadowcollector
			#pragma multi_compile_fog
			#pragma target 3.0
			ENDCG
		}

	}
}