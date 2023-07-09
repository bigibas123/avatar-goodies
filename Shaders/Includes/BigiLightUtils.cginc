#ifndef BIGI_LIGHT_UTILS_INCLUDE
#define BIGI_LIGHT_UTILS_INCLUDE

#include <UnityLightingCommon.cginc>
#include <AutoLight.cginc>
#include <UnityCG.cginc>


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

#endif
