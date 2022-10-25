#ifndef BIGI_SIMPLEVERT_INCLUDED
#define BIGI_SIMPLEVERT_INCLUDED

#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "AutoLight.cginc"


struct appdata {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

//intermediate
struct v2f
{
    UNITY_POSITION(pos);//float4 pos : SV_POSITION;
    half2 uv : TEXCOORD0; //texture coordinates
    SHADOW_COORDS(1) // put shadows data into TEXCOORD1
    float4 screenPos : TEXCOORD2;
    fixed4 diff : COLOR0; //diffusion shadow color/intensity
    fixed3 ambient : COLOR1; //ambient shadow color/intensity
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

v2f vert (appdata v)

{
    v2f o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_OUTPUT(v2f, o)
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    o.screenPos = ComputeScreenPos(o.pos);
    half3 worldNormal = UnityObjectToWorldNormal(v.normal);
    half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
    o.diff = nl * _LightColor0;
    o.diff.rgb += ShadeSH9(half4(worldNormal,1));
    TRANSFER_SHADOW(o);
    return o;
}

#endif