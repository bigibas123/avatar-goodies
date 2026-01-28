Shader "Bigi/Unlit/Geometry-1Grabpass"
{
    Properties {}
    SubShader
    {
        LOD 100
        GrabPass
        {
            "_GeometryMinus1Texture"
            Tags
            {
                "Queue"="Geometry-1"
            }
        }
        Pass
        {
            ZWrite Off
            ZTest On
            Blend SrcAlpha OneMinusSrcAlpha

            Tags
            {
                "RenderType" = "Transparent"
                "Queue" = "Transparent"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag alpha
            // make fog work
            #pragma multi_compile_fog
            sampler2D _GeometryMinus1Texture;

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = ComputeGrabScreenPos(o.vertex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2Dproj(_GeometryMinus1Texture, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
        UsePass "VertexLit/SHADOWCASTER"

    }
}