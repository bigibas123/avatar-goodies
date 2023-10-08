Shader "Bigi/Skybox/StarryNight"
{
    Properties
    {
        [MainTexture] _MainTex ("Texture", 2D) = "black" {}
    }

    SubShader
    {
        Tags
        {
            "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox"
        }
        Cull Off ZWrite Off

        CGINCLUDE
        #include "UnityCG.cginc"
        #include "../../lygia/generative/voronoi.hlsl"
        #include "../../lygia/generative/gerstnerWave.hlsl"
        #include "../../lygia/draw/digits.hlsl"
        #include "../../lygia/space/rotate.hlsl"
        #include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"

        UNITY_DECLARE_TEX2D(_MainTex);
        float4 _MainTex_ST;
        float _Rotation;


        struct appdata_t
        {
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        v2f vert(appdata_t v)
        {
            v2f o;
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            float time = (AudioLinkGetChronoTime(0, 0) * 45.0) % 360.0;
            float rads = time * (UNITY_PI / 180);
            float3 rotated = float3(rotate(v.vertex.xy, rads, float2(0.0, 0.0)), v.vertex.z);
            o.vertex = UnityObjectToClipPos(rotated);
            //o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = /*rotate(*/(v.texcoord + 1.0)/2.0 /* * 10.0 % 1.0,-rads,float2(0.5,0.5))*/;
            return o;
        }

        half4 skybox_frag(v2f i)
        {
            half3 c = UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
            c = AudioLinkData( ALPASS_CCLIGHTS + uint2( uint( i.uv.x * 8 ) + uint(i.uv.y * 16) * 8, 0 ) ).rgba;
            //c = half3(voronoi(i.texcoord * 10).rg,0.0);
            return half4(c, 1);
        }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            half4 frag(v2f i) : SV_Target { return skybox_frag(i); }
            ENDCG
        }
        /*
            Pass{
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                half4 frag (v2f i) : SV_Target { return skybox_frag(i); }
                ENDCG
            }
            Pass{
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                half4 frag (v2f i) : SV_Target { return skybox_frag(i); }
                ENDCG
            }
            Pass{
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                half4 frag (v2f i) : SV_Target { return skybox_frag(i); }
                ENDCG
            }
            Pass{
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                half4 frag (v2f i) : SV_Target { return skybox_frag(i); }
                ENDCG
            }
            Pass{
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                half4 frag (v2f i) : SV_Target { return skybox_frag(i); }
                ENDCG
            }
        */
    }
}