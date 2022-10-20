Shader "Unlit/BigiAudioLink_fragv3"
{
    Properties
    {
		_MainTex ("Texture", 2D) = "black" {}
        _Mask ("Mask", 2D) = "black" {}
        _LerpDist ("AudiLink Lerp Distance", Int) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100


        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            Cull Off
            ZWrite On
            CGPROGRAM
            #pragma instancing_options
            #pragma warning (default : 3206) // implicit truncation
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #pragma target 3.0
            

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
			#include "../../../AudioLink/Shaders/AudioLink.cginc"

            

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
            UNITY_INSTANCING_BUFFER_END(Props)


            //sampler2D _MainTex;
			UNITY_DECLARE_SCREENSPACE_TEXTURE(_MainTex);
            UNITY_DECLARE_TEX2D(_Mask);
            //UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
            int _LerpDist;
            float4 _MainTex_ST;
            float4 _Mask_ST;
			float _Threshold;


            //input
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            //intermediate
            struct v2f
            {
                float4 pos : SV_POSITION; //screen space location
                half2 uv : TEXCOORD0; //texture coordinates
                SHADOW_COORDS(1) // put shadows data into TEXCOORD1
                fixed4 diff : COLOR0; //diffusion shadow color/intensity
                fixed3 ambient : COLOR1; //ambient shadow color/intensity
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o)
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);


                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                o.diff = nl * _LightColor0;
                o.diff.rgb += ShadeSH9(half4(worldNormal,1));

                TRANSFER_SHADOW(o);
                return o;
            }


            

            float B_AlLerp(float2 xy) {
                float mainColor = AudioLinkData(xy).r;
                return lerp( mainColor, AudioLinkData(xy+float2(_LerpDist,0.0)).r, mainColor);
            }
        
            float4 B_AudioLink_Allchanels(float2 al_cords){
                float4 sound;
                sound.b = B_AlLerp(al_cords); //bass
                sound.g = B_AlLerp(al_cords+int2(0,1)); //low-mid
                sound.a = B_AlLerp(al_cords+int2(0,2)); //high-mid
                sound.r = B_AlLerp(al_cords+int2(0,3)); //treble
                return sound;
            }
			//Use of UNITY_MATRIX_MV is detected. To transform a vertex into view space, consider using UnityObjectToViewPos for better performance.

             //output
            struct fragOutput {
                fixed4 color : SV_Target;
            };
            

            fragOutput frag (v2f i)
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                fragOutput o;
                
                fixed4 orig_color= UNITY_SAMPLE_SCREENSPACE_TEXTURE(_MainTex, i.uv);
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed3 lighting = i.diff * shadow + i.ambient;
                o.color = orig_color * half4(lighting,1.0);
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


                    if(count > 0.0 && orig_color.b > 0.1){
                        o.color = fixed4(alc,1.0);
                    }
                
                }
            return o;
            }

            ENDCG
        }

        // shadow caster rendering pass, implemented manually
        // using macros from UnityCG.cginc
        Pass
        {
            Tags {"LightMode"="ShadowCaster"}
            Cull Off
            ZWrite On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"

            struct v2f { 
                V2F_SHADOW_CASTER;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
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
                UNITY_SETUP_INSTANCE_ID(i)
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}
