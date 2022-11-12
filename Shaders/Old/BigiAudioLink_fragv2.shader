Shader "Unlit/BigiAudioLink_fragv2"
{
    Properties
    {
		_MainTex ("Texture", 2D) = "black" {}
        _Mask ("Mask", 2D) = "black" {}
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
			#include "../Includes/AudioLink.cginc"
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

            struct fragOutput {
                fixed4 color : SV_Target;
                float depth: SV_Depth;
            };

            //sampler2D _MainTex;
			UNITY_DECLARE_TEX2D(_MainTex);
            UNITY_DECLARE_TEX2D(_Mask);
            float4 _MainTex_ST;
            float4 _Mask_ST;
			float _Threshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
			
            float4 B_AlLerp(float2 xy) {
                return lerp( AudioLinkData(xy), AudioLinkData(xy+float2(1.0,0.0)),0.5 );
            }
        
            float4 B_AudioLink_Allchanels(float2 al_cords){
                float4 sound;
                sound.b = B_AlLerp(al_cords).r; //bass
                sound.g = B_AlLerp(al_cords+int2(0,1)).r; //low-mid
                sound.a = B_AlLerp(al_cords+int2(0,2)).r; //high-mid
                sound.r = B_AlLerp(al_cords+int2(0,3)).r; //treble
                return sound;
            }
			//Use of UNITY_MATRIX_MV is detected. To transform a vertex into view space, consider using UnityObjectToViewPos for better performance.

            fragOutput frag (v2f i)
            {
                fragOutput o;
                o.depth = i.vertex.z;
                fixed4 orig_color= UNITY_SAMPLE_TEX2D(_MainTex, i.uv); 
                o.color = orig_color;

                if(AudioLinkIsAvailable()){
                    fixed4 mask = UNITY_SAMPLE_TEX2D(_Mask, i.uv);
                    fixed3 alc = fixed3(0.0,0.0,0.0);
                    fixed count = 0.0;
                
                    if(mask.b > 0.0){
                        fixed2 al_cords = ALPASS_AUDIOLINK;
                        fixed4 sound = B_AudioLink_Allchanels(ALPASS_AUDIOLINK);
                        count = count+mask.b;
                        alc = sound.rgb * mask.bbb;
                        
                    }
                    if(count > 0.0 && orig_color.b > 0.2){
                        o.color = fixed4(alc,1.0);
                    }
                
                }
            return o;
            }
            ENDCG
        }
    }
}
