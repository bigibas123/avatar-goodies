#ifndef BIGI_BASSDEFAULT_INCLUDED
#define BIGI_BASSDEFAULT_INCLUDED

#ifndef BIGI_EPSILON
#define BIGI_EPSILON
float Epsilon = 1e-10;
#endif

#ifndef BIGI_UNITY_DEFAULT_INCLUDES
#define BIGI_UNITY_DEFAULT_INCLUDES
#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "AutoLight.cginc"
#endif

#ifndef BIGI_COLOR_UTILS
#define BIGI_COLOR_UTILS
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
#endif

#endif