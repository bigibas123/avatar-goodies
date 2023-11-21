#ifndef BIGI_LIGHTUTILS_DEFINES
#define BIGI_LIGHTUTILS_DEFINES

#include "./BigiShaderParams.cginc"
#include "./BigiLightUtils.cginc"
#include <AutoLight.cginc>
#include <UnityLightingCommon.cginc>

#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting(_WorldSpaceLightPos0, i.normal, shadowAtt, _LightColor0, i.vertexLighting, i.lightmapUV, _MinAmbient, GET_AO(i.uv), _LightDiffuseness)

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting(_WorldSpaceLightPos0, i.normal, shadowAtt, _LightColor0, i.vertexLighting, i.lightmapUV, _MinAmbient, _LightDiffuseness)

#else
#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting(_WorldSpaceLightPos0, i.normal, shadowAtt, _LightColor0, i.vertexLighting,_MinAmbient, GET_AO(i.uv), _LightDiffuseness)

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting(_WorldSpaceLightPos0,i.normal,shadowAtt,_LightColor0,i.vertexLighting,_MinAmbient,_LightDiffuseness)


#endif



#endif
