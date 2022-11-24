Shader "Bigi/BS"
{
    Properties {}
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha

        LOD 100
        Tags
        {
            "Queue" = "Overlay"
        }
        GrabPass
        {
            "_BackgroundTexture"
            Tags
            {
                "Queue" = "Overlay"
            }
        }
        Pass
        {
            Name "OpaqueForwardBase"
            Tags
            {
                "RenderType" = "Opaque" "Queue" = "Geometry" "VRCFallback"="ToonCutout" "LightMode" = "ForwardBase"
            }
            Cull Back
            ZWrite On
            ZTest LEqual
            Blend One OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            sampler2D _BackgroundTexture;

            struct v2f
            {
                UNITY_POSITION(pos); //float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0; //texture coordinates
                float4 grabPos : TEXCOORD1;
                float4 screenPos : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o)
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.grabPos = ComputeGrabScreenPos(o.pos);
                o.screenPos = ComputeScreenPos(o.pos);
                return o;
            }


            struct fragOutput
            {
                fixed4 color : SV_Target;
            };


            float3 tTocPos(float4 i)
            {
                return i.xyz / i.w;
            }

            float4 cTotPos(float3 i, float w)
            {
                return float4(i * w, w);
            }

            half4 sub(half4 c1, half4 c2)
            {
                return c1 - c2;
            }

            half4 samp(sampler2D text, float3 npos, float w)
            {
                return half4(tex2Dproj(text, cTotPos(npos, w)).rgb, 1.0);
            }

            half4 sampf(sampler2D text, float3 npos, float m, float w)
            {
                npos.xy = floor(npos.xy * m) / m;
                return samp(text, npos, w);
            }

            half4 sampc(sampler2D text, float3 npos, float m, float w)
            {
                npos.xy = ceil(npos.xy * m) / m;
                return samp(text, npos, w);
            }


            const float tresh = 1e-10;
            const float mult = 100.0;

            fragOutput frag(v2f i)
            {
                fragOutput o;
                UNITY_INITIALIZE_OUTPUT(fragOutput, o);
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                float3 npos = tTocPos(i.grabPos);
                half4 center = samp(_BackgroundTexture, npos, i.grabPos.w);
                half4 end = half4(center.rgb * -1.0 + 1.0,center.a);
                o.color = end;
                return o;
            }
            ENDCG
        }

    }
}