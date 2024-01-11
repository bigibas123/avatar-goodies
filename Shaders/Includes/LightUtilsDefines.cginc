#pragma once

#include "./BigiShaderParams.cginc"
#include "./BigiLightUtils.cginc"
#include <AutoLight.cginc>
#include <UnityLightingCommon.cginc>

#ifndef BIGI_LIGHT_MACROS
#define BIGI_LIGHT_MACROS
#if defined(POINT) || defined(SPOT)
		#define GET_LIGHT_DIR() normalize(_WorldSpaceLightPos0.xyz - i.worldPos)
#else
		#define GET_LIGHT_DIR() _WorldSpaceLightPos0.xyz
#endif
#endif

#if defined(LIGHTMAP_ON) && defined(VERTEXLIGHT_ON) && defined(DYNAMICLIGHTMAP_ON)

#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.vertexLighting, \
i.lightmapUV, \
i.dynamicLightmapUV, \
_MinAmbient, \
GET_AO(i.uv), \
_LightSmoothness, \
_LightThreshold \
)

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.vertexLighting, \
i.lightmapUV, \
i.dynamicLightmapUV, \
_MinAmbient, \
1.0, \
_LightSmoothness, \
_LightThreshold \
)


#elif defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)

#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.lightmapUV, \
i.dynamicLightmapUV, \
_MinAmbient, \
GET_AO(i.uv), \
_LightSmoothness, \
_LightThreshold \
)

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.lightmapUV, \
i.dynamicLightmapUV, \
_MinAmbient, \
1.0, \
_LightSmoothness, \
_LightThreshold \
)


#elif defined(VERTEXLIGHT_ON) && defined(DYNAMICLIGHTMAP_ON)

#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.vertexLighting, \
i.dynamicLightmapUV, \
_MinAmbient, \
GET_AO(i.uv), \
_LightSmoothness, \
_LightThreshold \
)

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.vertexLighting, \
i.dynamicLightmapUV, \
_MinAmbient, \
1.0, \
_LightSmoothness, \
_LightThreshold \
)


#elif defined(LIGHTMAP_ON) && defined(VERTEXLIGHT_ON)

#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.vertexLighting, \
i.lightmapUV, \
_MinAmbient, \
GET_AO(i.uv), \
_LightSmoothness, \
_LightThreshold \
)

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.vertexLighting, \
i.lightmapUV, \
_MinAmbient, \
1.0, \
_LightSmoothness, \
_LightThreshold \
)

#elif defined(LIGHTMAP_ON)

#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.lightmapUV, \
_MinAmbient, \
GET_AO(i.uv), \
_LightSmoothness, \
_LightThreshold \
)

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.lightmapUV, \
_MinAmbient, \
1.0, \
_LightSmoothness, \
_LightThreshold \
)

#elif defined(VERTEXLIGHT_ON)

#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.vertexLighting, \
_MinAmbient, \
GET_AO(i.uv), \
_LightSmoothness, \
_LightThreshold \
)

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.vertexLighting, \
_MinAmbient, \
1.0, \
_LightSmoothness, \
_LightThreshold \
)

#elif defined(DYNAMICLIGHTMAP_ON)

#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.dynamicLightmapUV, \
_MinAmbient, \
GET_AO(i.uv), \
_LightSmoothness, \
_LightThreshold \
)

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.dynamicLightmapUV, \
_MinAmbient, \
1.0, \
_LightSmoothness, \
_LightThreshold \
)

#else

#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
_MinAmbient, \
GET_AO(i.uv), \
_LightSmoothness, \
_LightThreshold \
)

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
_MinAmbient, \
1.0, \
_LightSmoothness, \
_LightThreshold \
)

#endif

#ifdef VERTEXLIGHT_ON

#define BIGI_GETLIGHT_VERTEX(outName) \
const float3 outName = b_light::ProcessVertexLights( \
    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, \
    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb, \
    unity_4LightAtten0, o.worldPos, o.normal, _LightSmoothness, _LightThreshold \
) * _VertLightIntensity

#else
#define BIGI_GETLIGHT_VERTEX(outName) const float3 outName = 0

#endif
