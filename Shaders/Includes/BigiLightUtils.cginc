#ifndef BIGI_LIGHT_UTILS_INCLUDE
#define BIGI_LIGHT_UTILS_INCLUDE

#include <UnityCG.cginc>

#ifndef BIGI_EPSILON
#define BIGI_EPSILON
#define Epsilon UNITY_HALF_MIN
#endif


namespace b_light
{
    // A macro instead of a function because this works on more types without having to overload it a bunch of times
    // ReSharper disable once CppInconsistentNaming
    # define doStep(val) smoothstep(0.0, lightDiffuseness, val) // Maybe change to slidable window with configurable width. Currently you just mostly get darker

    half3 GetAmbient(
        in const float3 worldNormal,
        in const float minAmbient,
        in const float4 ambientOcclusion,
        #ifdef LIGHTMAP_ON
        in const float2 lightmapUv,
        #endif
        in const float lightDiffuseness
    )
    {
        half3 ret = 0;


        #ifdef LIGHTMAP_ON

        ret += DecodeLightmap(
                    UNITY_SAMPLE_TEX2D(unity_Lightmap, lightmapUv)
                    );
        
        #if defined(DIRLIGHTMAP_COMBINED)
        float4 lightmapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(
                    unity_LightmapInd, unity_Lightmap, lightmapUv
                );
            ret = DecodeDirectionalLightmap(
                ret, lightmapDirection, worldNormal
            );
        #endif
        #endif

        #if UNITY_SHOULD_SAMPLE_SH
            ret += max(0,ShadeSH9(half4(worldNormal, 1)));
        #endif

        ret = doStep(ret);
        return (minAmbient < Epsilon ? ret : max(ret, half3(minAmbient, minAmbient, minAmbient))) * clamp(ambientOcclusion, 0.75, 1.0);
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

    half fade_shadow(
        in const float3 worldNormal,
        #ifdef LIGHTMAP_ON
        in const float2 lightmapUv,
        #endif
        in half attenuation
    )
    {
        #if HANDLE_SHADOWS_BLENDING_IN_GI
        float viewZ = dot(_WorldSpaceCameraPos - worldNormal, UNITY_MATRIX_V[2].xyz);
        float shadowFadeDistance = UnityComputeShadowFadeDistance(worldNormal, viewZ);
        float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
        #ifdef LIGHTMAP_ON
        float bakedAttenuation = UnitySampleBakedOcclusion(lightmapUv,worldNormal);
        #else
        float bakedAttenuation = 0;
        #endif

        attenuation = UnityMixRealtimeAndBakedShadows(
            attenuation, bakedAttenuation, shadowFade
        );
        #endif
        return attenuation;
    }

    fixed4 GetLighting(
        const in float4 worldLightPos,
        const in float3 worldNormal,
        const in half shadowAttenuation,
        const in half4 lightColor,
        #ifdef VERTEXLIGHT_ON
        const in float3 vertex,
        #endif
        #ifdef LIGHTMAP_ON
        const in float2 lightmapUv,
        #endif
        const in float minAmbient,
        const in float4 ambientOcclusion,
        const in float lightDiffuseness
    )
    {
        const half3 ambient = GetAmbient(
            worldNormal,
            minAmbient,
            ambientOcclusion,
            #if defined(LIGHTMAP_ON)
            lightmapUv,
            #endif
            lightDiffuseness
        );
        const half3 ambientStepped = ambient;


        const float nl = max(0, dot(worldNormal, worldLightPos.xyz));

        const float fadedAttenuation = fade_shadow(
            worldNormal,
            #ifdef LIGHTMAP_ON
            lightmapUv,
            #endif
            shadowAttenuation
        );

        const float lightIntensity = doStep(nl * fadedAttenuation);
        #ifdef VERTEXLIGHT_ON
        const fixed3 vertexStepped = vertex; // stepping taken care of in vertex functions, (maybe change later to move all shader parameters out of toon function)
        #endif
        const fixed3 diff = lightIntensity * lightColor;
        const fixed4 total = fixed4(
            diff
            + ambientStepped
            #ifdef VERTEXLIGHT_ON
            + vertexStepped
            #endif
            , 1.0
        );
        return clamp(total, -1.0, 1.0);
    }

    //Unity.cginc Shade4PointLights 
    float3 bigi_Shade4PointLights(
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

    float3 ProcessVertexLights(
        float4 lightPosX, float4 lightPosY, float4 lightPosZ,
        float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
        float4 lightAttenSq,
        float3 pos, float3 normal, in const float lightDiffuseness
    )
    {
        float3 ret = 0;

        #ifdef VERTEXLIGHT_ON
        ret += bigi_Shade4PointLights (
            lightPosX, lightPosY, lightPosZ,
            lightColor0, lightColor1, lightColor2, lightColor3,
            lightAttenSq, pos, normal, lightDiffuseness);
        #endif

        return ret;
    }
}

#endif
