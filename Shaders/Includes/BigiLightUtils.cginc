#ifndef BIGI_LIGHT_UTILS_INCLUDE
#define BIGI_LIGHT_UTILS_INCLUDE

namespace b_light {

    fixed4 GetLighting(float3 normal, float4 worldSpaceLightPos, fixed4 lightColor, fixed shadowAttenuation, float ambientOcclusion){
        half3 worldNormal = UnityObjectToWorldNormal(normal);
        half3 ambient = max(ShadeSH9(half4(worldNormal,1)), half3(0.05,0.05,0.05)) * clamp(ambientOcclusion,0.75,1.0);
        float nl = max(0, dot(worldNormal, worldSpaceLightPos.xyz));
        float lightIntensity = smoothstep(0, 0.1, nl);
        fixed3 diff = lightIntensity * lightColor;
        return fixed4((diff*shadowAttenuation) + ambient,1.0);
   }

    fixed4 GetLighting(float3 normal, float4 worldSpaceLightPos, fixed4 lightColor, fixed shadowAttenuation){
        return GetLighting(normal,worldSpaceLightPos,lightColor,shadowAttenuation,1.0);
    }
    fixed4 GetLighting(float3 normal, float4 worldSpaceLightPos, fixed4 lightColor){
        return GetLighting(normal,worldSpaceLightPos,lightColor,1.0,1.0);
    }
}
#endif