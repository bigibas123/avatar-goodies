Shader "Unlit/BigiAudioLink"
{
    Properties
    {
		_MainTex ("Texture", 2D) = "black" {}
		_Threshold ("Sound threshold", Range(0.0,0.5)) = 0.05
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include "../../../AudioLink/Shaders/AudioLink.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            //sampler2D _MainTex;
			UNITY_DECLARE_TEX2D(_MainTex);
            float4 _MainTex_ST;
			float _Threshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
			
			float4 decideal(float4 sound, float4 tex){
				if(sound.r > _Threshold || sound.b > _Threshold || sound.b > _Threshold){
					return sound;
				}else{
					return tex;
				}
			}
			
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
				if(col.b > 0.1) {
					//bass, low-mid, high-mid and treble
					float2 al_cords = ALPASS_AUDIOLINK;
					float4 sound = float4(AudioLinkLerp(al_cords).r,AudioLinkLerp(al_cords+int2(0,1)).r,AudioLinkLerp(al_cords+int2(0,2)).r,AudioLinkLerp(al_cords+int2(0,3)).r);
					float4 o = float4(0.0,0.0,0.0,1.0);
					
					if(sound.r > _Threshold || sound.g > _Threshold || sound.a > _Threshold){
						o.r = sound.r;
						o.g = sound.g;
						o.b = sound.a;
					}
					return decideal(o,col);
				}
					return col;
            }
            ENDCG
        }
    }
}
