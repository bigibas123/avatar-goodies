#pragma once
#include <HLSLSupport.cginc>

#ifndef MULTI_TEXTURE
    UNITY_DECLARE_TEX2D(_MainTex);
    float4 _MainTex_ST;
    #define GET_TEX_COLOR(uv) UNITY_SAMPLE_TEX2D(_MainTex, uv)
    #define GET_MASK_COLOR(uv) UNITY_SAMPLE_TEX2D_SAMPLER(_Mask, _MainTex, uv)
    #define GET_AO(uv) UNITY_SAMPLE_TEX2D_SAMPLER(_OcclusionMap, _MainTex, uv)
    #define GET_NORMAL(uv) UNITY_SAMPLE_TEX2D_SAMPLER(_BumpMap, _MainTex, uv)

    #define DO_TRANSFORM(tc) TRANSFORM_TEX(v.texcoord, _MainTex);

#else
    UNITY_DECLARE_TEX2DARRAY(_MainTexArray);
    float4 _MainTexArray_ST;
    uniform int _OtherTextureId;
    #define GET_TEX_COLOR(uv) UNITY_SAMPLE_TEX2DARRAY(_MainTexArray, float3(uv,_OtherTextureId))
    #define GET_MASK_COLOR(uv) UNITY_SAMPLE_TEX2D_SAMPLER(_Mask, _MainTexArray, uv)
    #define GET_AO(uv) UNITY_SAMPLE_TEX2D_SAMPLER(_OcclusionMap, _MainTexArray, uv)
    #define GET_NORMAL(uv) UNITY_SAMPLE_TEX2D_SAMPLER(_BumpMap, _MainTexArray, uv)

    #define DO_TRANSFORM(tc) TRANSFORM_TEX(v.texcoord, _MainTexArray);

#endif

#ifndef OTHER_BIGI_TEXTURES
#define OTHER_BIGI_TEXTURES

UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask);
UNITY_DECLARE_TEX2D_NOSAMPLER(_OcclusionMap);
UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap);
UNITY_DECLARE_TEX2D(_Spacey);
float4 _Spacey_ST;
#endif
