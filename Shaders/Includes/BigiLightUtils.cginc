#ifndef BIGI_LIGHT_UTILS_INCLUDE
#define BIGI_LIGHT_UTILS_INCLUDE

#include <UnityLightingCommon.cginc>
#include <AutoLight.cginc>
#include <UnityCG.cginc>
#include "./BigiShaderParams.cginc"

namespace b_light
{
    fixed4 GetLighting(const float3 worldNormal, const half shadowAttenuation, const float4 ambientOcclusion)
    {
        const half3 ambient = max(ShadeSH9(half4(worldNormal, 1)), half3(_MinAmbient, _MinAmbient, _MinAmbient)) * clamp(ambientOcclusion, 0.75, 1.0);
        const float nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
        const float lightIntensity = smoothstep(0.0, 0.1, nl * shadowAttenuation);
        const fixed3 diff = lightIntensity * _LightColor0;
        return fixed4((diff) + ambient, 1.0);
    }

    fixed4 GetLighting(const float3 normal, const half shadowAttenuation) { return GetLighting(normal, shadowAttenuation, 1.0); }
}

#define BIGI_GETLIGHT_DEFAULT(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting(i.normal, shadowAtt, UNITY_SAMPLE_TEX2D_SAMPLER(_AOMap, _MainTex, i.uv))

#define BIGI_GETLIGHT_NOAO(outName) UNITY_LIGHT_ATTENUATION(shadowAtt,i,i.worldPos); \
const fixed4 outName = b_light::GetLighting(i.normal,shadowAtt)
#endif
