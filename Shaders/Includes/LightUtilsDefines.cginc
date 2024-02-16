#ifndef BIGI_LIGHTUTILDEFINES_H
#define BIGI_LIGHTUTILDEFINES_H

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

#ifndef B_LIGHTMAP_ARG
	#ifdef LIGHTMAP_ON
		#define B_LIGHTMAP_ARG i.lightmapUV,
	#else
		#define B_LIGHTMAP_ARG 
	#endif
#endif

#ifndef B_DYNAMIC_LIGHTMAP_ARG
	#ifdef DYNAMICLIGHTMAP_ON
		#define B_DYNAMIC_LIGHTMAP_ARG i.dynamicLightmapUV,
	#else
		#define B_DYNAMIC_LIGHTMAP_ARG
	#endif
#endif


#endif


#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.vertexLighting, \
_Reflectivity, \
B_LIGHTMAP_ARG \
B_DYNAMIC_LIGHTMAP_ARG \
_MinAmbient, \
GET_AO(GETUV), \
_LightSmoothness, \
_LightThreshold, \
_Transmissivity \
)

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting( \
GET_LIGHT_DIR(), \
i.worldPos, \
i.normal, \
shadowAtt, \
_LightColor0, \
i.vertexLighting, \
_Reflectivity, \
B_LIGHTMAP_ARG \
B_DYNAMIC_LIGHTMAP_ARG \
_MinAmbient, \
1.0, \
_LightSmoothness, \
_LightThreshold, \
_Transmissivity \
)


#ifdef VERTEXLIGHT_ON

#define BIGI_GETLIGHT_VERTEX(outName) \
const float3 outName = b_light::ProcessVertexLights( \
    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, \
    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb, \
    unity_4LightAtten0, o.worldPos, o.normal \
) * _VertLightIntensity

#else
#define BIGI_GETLIGHT_VERTEX(outName) const float3 outName = 0

#endif
#endif
