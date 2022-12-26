#ifndef BIGI_V1_SHADERPARAMS
// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11
#define BIGI_V1_SHADERPARAMS


#ifndef BIGI_V1_TEXTURES
#define BIGI_V1_TEXTURES

UNITY_DECLARE_TEX2D(_MainTex);
float4 _MainTex_ST;
UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask);
UNITY_DECLARE_TEX2D_NOSAMPLER(_AOMap);
UNITY_DECLARE_TEX2D(_Spacey);
float4 _Spacey_ST;
#endif

#ifndef BIGI_V1_UNIFORMS
#define BIGI_V1_UNIFORMS
uniform int _DMXGroup;
uniform half _AudioIntensity;
uniform int _ColorChordIndex;
uniform float _OutlineWidth;
uniform float _SpaceyScaling;
uniform half _UseBassIntensity;
uniform half _EmissionStrength;
uniform float _AddLightIntensity;
uniform float _MinAmbient;
/*
const static uint _DecalCount = 1;
uniform float _DecalPositionMappings[_DecalCount*4u];
*/
#endif

#ifndef BIGI_DEFAULT_FRAGOUT
#define BIGI_DEFAULT_FRAGOUT

struct fragOutput
{
    fixed4 color : SV_Target;
};
#endif

#ifndef BIGI_EPSILON
#define BIGI_EPSILON
#include <UnityCG.cginc>
float Epsilon = 1e-10;
#endif

#endif
