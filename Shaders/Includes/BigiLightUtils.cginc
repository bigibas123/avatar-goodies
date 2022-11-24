#ifndef BIGI_LIGHT_UTILS_INCLUDE
#define BIGI_LIGHT_UTILS_INCLUDE

#include <UnityLightingCommon.cginc>
#include <AutoLight.cginc>
#include <UnityCG.cginc>

namespace b_light
{
    fixed4 GetLighting(
        const float3 normal, const half shadowAttenuation, const float4 ambientOcclusion
    )
    {
        half3 world_normal = UnityObjectToWorldNormal(normal);
        const half3 ambient = max(ShadeSH9(half4(world_normal, 1)), half3(0.05, 0.05, 0.05)) * clamp(ambientOcclusion, 0.75, 1.0);
        const float nl = max(0, dot(world_normal, _WorldSpaceLightPos0.xyz));
        const float lightIntensity = smoothstep(0.0, 0.1, nl * shadowAttenuation);
        const fixed3 diff = lightIntensity * _LightColor0 ;
        return fixed4((diff) + ambient,1.0);
    }

    fixed4 GetLighting(const float3 normal, const half shadowAttenuation)
    {
        return GetLighting(normal, shadowAttenuation, 1.0);
    }

    fixed4 GetLighting(const float3 normal)
    {
        return GetLighting(normal, 1.0, 1.0);
    }
}
#define BIGI_GETLIGHT_DEFAULT b_light::GetLighting(i.normal, LIGHT_ATTENUATION(i), UNITY_SAMPLE_TEX2D_SAMPLER(_AOMap, _MainTex, i.uv))
#define BIGI_GETLIGHT_NOAO b_light::GetLighting(i.normal,LIGHT_ATTENUATION(i))
#endif
