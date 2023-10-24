#ifndef BIGI_TOONVERT_INCLUDED
#define BIGI_TOONVERT_INCLUDED


#include <UnityCG.cginc>
#include <AutoLight.cginc>
#include "./BigiShaderParams.cginc"

#ifndef BIGI_DEFAULT_FRAGOUT
#define BIGI_DEFAULT_FRAGOUT
struct fragOutput {
    fixed4 color : SV_Target;
};
#endif
#ifndef BIGI_DEFAULT_APPDATA
#define BIGI_DEFAULT_APPDATA
struct appdata {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float4 texcoord : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
#endif

//intermediate
struct v2f {
    UNITY_POSITION(pos); //float4 pos : SV_POSITION;

    float3 normal : NORMAL; //(World) Normal
    half2 uv : TEXCOORD0; //texture coordinates
    UNITY_LIGHTING_COORDS(1, 2)
    UNITY_FOG_COORDS(3)
    float3 vertexLighting : TEXCOORD4;
    float4 staticTexturePos : TEXCOORD5;
    float3 worldPos: TEXCOORD6;
    float3 tangent : TEXCOORD7; // vect in left direction of texture coordinates
    float3 bitangent : TEXCOORD8; // vect in up direction of texture coordinates
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

#ifndef BIGI_V1_TOONVERTSHADER
#define BIGI_V1_TOONVERTSHADER

v2f vert(appdata v)

{
    v2f o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    o.pos = UnityObjectToClipPos(v.vertex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.uv = DO_TRANSFORM(v.texcoord)
    
    #if defined(DIRECTIONAL) || defined(POINT) || defined(SPOT) || defined(DIRECTIONAL) || defined(POINT_COOKIE) || defined(DIRECTIONAL_COOKIE)
    o._ShadowCoord = 0;
    #endif
    
    UNITY_TRANSFER_SHADOW(o, o.pos)
    UNITY_TRANSFER_LIGHTING(o, o.pos)
    UNITY_TRANSFER_FOG(o, o.pos);
    o.staticTexturePos = ComputeScreenPos(o.pos);
    //TODO make this object space relative or something?
    
    o.worldPos = UnityObjectToWorldDir(v.vertex);
   
    o.vertexLighting = float3(0.0, 0.0, 0.0);
    #ifdef VERTEXLIGHT_ON
    for (int index = 0; index < 4; index++)
    {
        float4 lightPosition = float4(
            unity_4LightPosX0[index],
            unity_4LightPosY0[index],
            unity_4LightPosZ0[index], 1.0
        );

        const float3 vertexToLightSource = lightPosition.xyz - o.worldPos.xyz;    
        const float3 lightDirection = normalize(vertexToLightSource);
        const float squaredDistance = dot(vertexToLightSource, vertexToLightSource);
        float attenuation = 1.0 / (1.0 + unity_4LightAtten0[index] * squaredDistance);
        float3 diffuseReflection = attenuation * unity_LightColor[index].rgb * max(0.0, dot(o.normal, lightDirection));

        o.vertexLighting = o.vertexLighting + diffuseReflection;
    }
    #endif
    
    o.tangent = UnityObjectToWorldDir(v.tangent);
    
    const float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
    o.bitangent = cross(o.normal, o.tangent) * tangentSign;

    return o;
}
#endif

#endif
