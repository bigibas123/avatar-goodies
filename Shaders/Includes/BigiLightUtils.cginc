#ifndef BIGI_LIGHT_UTILS_INCLUDE
#define BIGI_LIGHT_UTILS_INCLUDE

namespace b_light
{
    fixed4 GetLighting(const float3 normal, float4 worldSpaceLightPos, const fixed4 lightColor, const fixed shadowAttenuation,
                       const float ambientOcclusion)
    {
        half3 world_normal = UnityObjectToWorldNormal(normal);
        const half3 ambient = max(ShadeSH9(half4(world_normal, 1)), half3(0.05, 0.05, 0.05)) * clamp(ambientOcclusion, 0.75, 1.0);
        const float nl = max(0, dot(world_normal, worldSpaceLightPos.xyz));
        const float lightIntensity = smoothstep(0, 0.1, nl);
        const fixed3 diff = lightIntensity * lightColor;
        return fixed4((diff * shadowAttenuation) + ambient, 1.0);
    }

    fixed4 GetLighting(const float3 normal, const float4 worldSpaceLightPos, const fixed4 lightColor,
                       const fixed shadowAttenuation)
    {
        return GetLighting(normal, worldSpaceLightPos, lightColor, shadowAttenuation, 1.0);
    }

    fixed4 GetLighting(const float3 normal, const float4 worldSpaceLightPos, const fixed4 lightColor)
    {
        return GetLighting(normal, worldSpaceLightPos, lightColor, 1.0, 1.0);
    }
}
#endif
