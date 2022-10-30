#ifndef BIGI_TOONVERT_INCLUDED
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members normal)
#pragma exclude_renderers d3d11
#define BIGI_TOONVERT_INCLUDED

#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "AutoLight.cginc"
#include "./PassDefault.cginc"

//intermediate
struct v2f
{
    UNITY_POSITION(pos);//float4 pos : SV_POSITION;
    float3 normal : NORMAL;
    half2 uv : TEXCOORD0; //texture coordinates
    SHADOW_COORDS(1) // put shadows data into TEXCOORD1
    float4 screenPos : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

#ifndef BIGI_DEFAULT_FRAGOUT
#define BIGI_DEFAULT_FRAGOUT
struct fragOutput {
    fixed4 color : SV_Target;
};
#endif

#ifndef BIGI_V1_TEXTURES
#define BIGI_V1_TEXTURES
UNITY_DECLARE_TEX2D(_MainTex);
UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask);
UNITY_DECLARE_TEX2D(_Spacey);
#endif

v2f vert (appdata_base v)

{
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f, o)
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = v.texcoord;
    o.normal = v.normal;
    o.screenPos = ComputeScreenPos(o.pos);
    TRANSFER_SHADOW(o)
    return o;
}

#endif