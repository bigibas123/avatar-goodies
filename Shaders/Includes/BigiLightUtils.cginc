#ifndef BIGI_LIGHT_UTILS_INCLUDE
#define BIGI_LIGHT_UTILS_INCLUDE

#include <UnityLightingCommon.cginc>
#include <UnityCG.cginc>


namespace b_light
{
    # define doStep(val) smoothstep(0.0, lightDiffuseness, val)

    half3 GetAmbient(
        const in float3 worldNormal,
        const in float minAmbient,
        const in float4 ambientOcclusion
    )
    {
        return max(
                ShadeSH9(half4(worldNormal, 1)),
                half3(minAmbient, minAmbient, minAmbient)
            ) *
            clamp(ambientOcclusion, 0.75, 1.0);
    }

    fixed3 GetWorldLightIntensity(
        const in half shadowAttenuation,
        const in float4 worldLightPos,
        const in float3 worldNormal
    )
    {
        const float nl = max(0, dot(worldNormal, worldLightPos.xyz));
        const float lightIntensity = nl * shadowAttenuation;
        return lightIntensity;
    }

    fixed4 GetLighting(
        const in float4 worldLightPos,
        const in float3 worldNormal,
        const in half shadowAttenuation,
        const in half4 lightColor,
        const in float3 vertex,
        const in float minAmbient,
        const in float4 ambientOcclusion,
        const in float lightDiffuseness
    )
    {
        const half3 ambient = GetAmbient(worldNormal, minAmbient, ambientOcclusion);

        const float nl = max(0, dot(worldNormal, worldLightPos.xyz));

        const float lightIntensity = doStep(nl * shadowAttenuation);
        const fixed3 vertexStepped = vertex;
        const fixed3 diff = lightIntensity * lightColor;

        return fixed4(diff + ambient + vertexStepped, 1.0);
    }

    //Unity.cginc Shade4PointLights 
    float3 ProcessVertexLights(
        float4 lightPosX, float4 lightPosY, float4 lightPosZ,
        float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
        float4 lightAttenSq,
        float3 pos, float3 normal, in const float lightDiffuseness
    )
    {
        // to light vectors
        float4 toLightX = lightPosX - pos.x;
        float4 toLightY = lightPosY - pos.y;
        float4 toLightZ = lightPosZ - pos.z;
        // squared lengths
        float4 lengthSq = 0;
        lengthSq += toLightX * toLightX;
        lengthSq += toLightY * toLightY;
        lengthSq += toLightZ * toLightZ;
        // don't produce NaNs if some vertex position overlaps with the light
        lengthSq = max(lengthSq, 0.000001);

        // NdotL
        float4 ndotl = 0;
        ndotl += toLightX * normal.x;
        ndotl += toLightY * normal.y;
        ndotl += toLightZ * normal.z;
        // correct NdotL
        float4 corr = rsqrt(lengthSq);
        ndotl = max(float4(0, 0, 0, 0), ndotl * corr);
        // attenuation
        float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
        float4 diff = doStep(ndotl * atten);
        // final color
        float3 col = 0;
        col += lightColor0 * diff.x;
        col += lightColor1 * diff.y;
        col += lightColor2 * diff.z;
        col += lightColor3 * diff.w;
        return col;
    }

    fixed4 GetLighting(
        const in float4 worldLightPos,
        const float3 normal,
        const half shadowAttenuation,
        const half4 lightColor,
        const float3 vertex,
        const float minAmbient,
        const float lightDiffuseness
    )
    {
        return GetLighting(worldLightPos, normal, shadowAttenuation, lightColor, vertex, minAmbient, 1.0, lightDiffuseness);
    }
}

#endif
