Shader "Bigi/TransparentSkybox"
{
    Properties
    {
    }
    
    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="TransparentCutout" "PreviewType"="Skybox" "IgnoreProjector"="True"  }
        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
    
        Pass
        {
    
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            
            #include "UnityCG.cginc"
    
            struct appdata_t
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
    
            struct v2f
            {
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };
    
            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }
    
            fixed4 frag (v2f i) : SV_Target
            {
                half4 tex = half4(0.0,0.0,0.0,0.0);
                clip(-1);
                return tex;
            }
            ENDCG
        }
    }

    Fallback Off
}
