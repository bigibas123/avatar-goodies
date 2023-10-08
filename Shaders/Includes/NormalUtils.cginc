#ifndef BIGI_NORMALUTILS
#define BIGI_NORMALUTILS

#include <UnityCG.cginc>

namespace b_normalutils
{
    float3 recalc_normals(const in float3 standardNormal, const in float4 normalMap, const in float3 tangent, const in float3 biTangent)
    {
        float3x3 TBN = float3x3(normalize(tangent), normalize(biTangent), normalize(standardNormal));
        TBN = transpose(TBN);
        float3 worldnormal = mul(TBN, UnpackNormal(normalMap));
        return worldnormal;
    }
}

#endif
