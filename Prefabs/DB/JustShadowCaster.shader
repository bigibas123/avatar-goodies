Shader "Bigi/Unlit/ShadowCaster"
{
    Properties {}
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100
        UsePass "VertexLit/SHADOWCASTER"

    }
}