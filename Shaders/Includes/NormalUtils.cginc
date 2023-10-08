#ifndef BIGI_NORMALUTILS
#define BIGI_NORMALUTILS

#include <UnityCG.cginc>

namespace b_normalutils
{
    float3 recalculate_normals(const in float3 standard_normal, const in float4 normal_map, const in float3 tangent, const in float3 bi_tangent)
    {
        float3x3 TBN = float3x3(normalize(tangent), normalize(bi_tangent), normalize(standard_normal));
        TBN = transpose(TBN);
        float3 world_normal = mul(TBN, UnpackNormal(normal_map));
        return world_normal;
    }
}

#endif
