#ifndef BIGI_BASSDEFAULT_INCLUDED
#define BIGI_BASSDEFAULT_INCLUDED
float Epsilon = 1e-10;

#pragma instancing_options assumeuniformscaling
#pragma multi_compile_instancing
#pragma multi_compile_fwdbase
#pragma multi_compile_fwdbasealpha
#pragma multi_compile_lightpass
#pragma multi_compile_shadowcollector
#pragma target 3.0


#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "AutoLight.cginc"

half3 RGBtoHCV(in half3 RGB)
{
    // Based on work by Sam Hocevar and Emil Persson
    half4 P = (RGB.g < RGB.b) ? half4(RGB.bg, -1.0, 2.0/3.0) : half4(RGB.gb, 0.0, -1.0/3.0);
    half4 Q = (RGB.r < P.x) ? half4(P.xyw, RGB.r) : half4(RGB.r, P.yzx);
    half C = Q.x - min(Q.w, Q.y);
    half H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
    return half3(H, C, Q.x);
}

half3 RGBToHSV(in half3 c)
{
    half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    half4 p = lerp( half4( c.bg, K.wz ), half4( c.gb, K.xy ), step( c.b, c.g ) );
    half4 q = lerp( half4( p.xyw, c.r ), half4( c.r, p.yzx ), step( p.x, c.r ) );
    half d = q.x - min( q.w, q.y );
    half e = 1.0e-10;
    return half3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

half3 HSVToRGB(in half3 c)
{
    half4 K = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    half3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

UNITY_DECLARE_TEX2D(_MainTex);
UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask);
UNITY_DECLARE_TEX2D(_Spacey);

uniform half _SpaceyScaling;
uniform int _DMXGroup;
uniform half _ALThreshold;
uniform int _ColorChordIndex;
uniform half _ExtraLightIntensity;




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



struct fragOutput {
    fixed4 color : SV_Target;
};

#endif