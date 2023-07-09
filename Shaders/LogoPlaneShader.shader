Shader "Bigi/LogoPlane" {
	Properties {
		[MainTexture] _MainTex ("Texture", 2D) = "black" {}
		_CellNumber ("CellNumber", Int) = 0
		_AL_General_Intensity("Audiolink Intensity",Range(0.0,1.0)) = 0.0
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
		#pragma multi_compile __ EXTERNAL_AUDIOLINK
		#pragma target 3.0
		
		#include <UnityCG.cginc>
		const static float2 cell_size = float2(1.0 / GRID_SIZE, 1.0 / GRID_SIZE);
		uniform uint _CellNumber;
		uniform float _AL_General_Intensity;

		#include "./Includes/LightUtilsDefines.cginc"
		#include "./Includes/SoundUtilsDefines.cginc"

		struct appdata {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			UNITY_VERTEX_INPUT_INSTANCE_ID };

		//intermediate
		struct v2f {
			UNITY_POSITION(pos); //float4 pos : SV_POSITION;
			float3 normal : NORMAL;
			half2 uv : TEXCOORD0; //texture coordinates
			LIGHTING_COORDS(1, 2) UNITY_FOG_COORDS(3) //put for info into TEXCOORD2
			float3 worldPos: TEXCOORD4;
			float4 sound: COLOR0;
			float4 soundIntensity: PSIZE0;
			UNITY_VERTEX_INPUT_INSTANCE_ID
			UNITY_VERTEX_OUTPUT_STEREO
		};

		v2f vert(appdata v)
		{
			v2f o;
			UNITY_INITIALIZE_OUTPUT(v2f, o)
			UNITY_SETUP_INSTANCE_ID(v);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			UNITY_TRANSFER_INSTANCE_ID(v, o);
			o.pos = UnityObjectToClipPos(v.vertex);

			const uint2 coords = uint2(_CellNumber % GRID_SIZE, floor(_CellNumber / GRID_SIZE));
			const half2 start_coord = cell_size * coords;

			const half2 offset = TRANSFORM_TEX(v.texcoord, _MainTex) * cell_size;
			o.uv = start_coord + offset;
			o.normal = UnityObjectToWorldNormal(v.normal);
			
			GET_SOUND_SETTINGS(set);
			set.AL_Theme_Weight = _AL_General_Intensity;
			
			GET_SOUND_COLOR_CALL(set,scol);
			o.sound = half4(scol.rgb,1.0);
			o.soundIntensity = scol.a;
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);
			UNITY_TRANSFER_LIGHTING(o, o.pos);
			UNITY_TRANSFER_FOG(o, o.pos);
			return o;
		}

		fragOutput frag(v2f i)
		{
			fragOutput o;
			UNITY_INITIALIZE_OUTPUT(fragOutput, o);
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i) const fixed4 orig_color = UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
			clip(orig_color.a - Epsilon);
			BIGI_GETLIGHT_NOAO(lighting);
			const fixed4 normalColor = orig_color * lighting;
			o.color = lerp(normalColor,fixed4(i.sound.rgb, normalColor.a), i.soundIntensity);
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
			Name "TransparentForwardBaseFront"
			Cull Back
			ZWrite Off
			ZTest LEqual
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			ENDCG
		}

	}
}