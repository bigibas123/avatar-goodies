// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#ifndef BIGI_TOONVERT_INCLUDED
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members normal)
#pragma exclude_renderers d3d11
#define BIGI_TOONVERT_INCLUDED

#include <UnityCG.cginc>
#include <AutoLight.cginc>
#include "./BigiShaderParams.cginc"

//intermediate
struct v2f
{
    UNITY_POSITION(pos); //float4 pos : SV_POSITION;
    
    float3 normal : NORMAL;
    half2 uv : TEXCOORD0; //texture coordinates
    UNITY_LIGHTING_COORDS(1, 2)
    UNITY_FOG_COORDS(3)
    float4 staticTexturePos : TEXCOORD4;
    float3 worldPos: TEXCOORD5;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

#ifndef BIGI_DEFAULT_FRAGOUT
#define BIGI_DEFAULT_FRAGOUT
struct fragOutput {
    fixed4 color : SV_Target;
};
#endif

#ifndef BIGI_V1_TOONVERTSHADER
#define BIGI_V1_TOONVERTSHADER

v2f vert(appdata_base v)

{
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f, o)
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    o.pos = UnityObjectToClipPos(v.vertex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.staticTexturePos = ComputeScreenPos(o.pos);
    UNITY_TRANSFER_LIGHTING(o, o.pos)
    //TRANSFER_SHADOW(o)
    UNITY_TRANSFER_FOG(o, o.pos);
    return o;
}
#endif

#endif
