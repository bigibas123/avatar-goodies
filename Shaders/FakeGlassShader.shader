Shader "Bigi/FakeGlass"
{
    Properties {}
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags
        {
            "RenderType" = "Opaque" "Queue" = "Geometry+1" "IgnoreProjector" = "True"
        }

        LOD 100
        GrabPass
        {
            "_BackgroundTexture"
        }

        Pass
        {
            Tags
            {
                "RenderType" = "Opaque" "Queue"="Overlay+1"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 grabPos : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                // use UnityObjectToClipPos from UnityCG.cginc to calculate 
                // the clip-space of the vertex
                o.pos = UnityObjectToClipPos(v.vertex);

                // use ComputeGrabScreenPos function from UnityCG.cginc
                // to get the correct texture coordinate
                o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;
            }

            sampler2D _BackgroundTexture;

            half4 frag(v2f i) : SV_Target
            {
                half4 bgcolor = tex2Dproj(_BackgroundTexture, i.grabPos);
                bgcolor.a = 1.0;
                return bgcolor;
            }
            ENDCG
        }

    }
}