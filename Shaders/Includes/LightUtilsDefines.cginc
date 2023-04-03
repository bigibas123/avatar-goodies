#ifndef BIGI_LIGHTUTILS_DEFINES
#define BIGI_LIGHTUTILS_DEFINES

#include "./BigiShaderParams.cginc"
#include "./BigiLightUtils.cginc"

#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting(i.normal, shadowAtt, UNITY_SAMPLE_TEX2D_SAMPLER(_AOMap, _MainTex, i.uv))

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting(i.normal,shadowAtt)


#endif