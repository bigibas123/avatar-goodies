#ifndef BIGI_V1_SHADERPARAMS
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

//Audiolink stuffs
uniform half _AudioIntensity;
uniform int _ColorChordIndex;
uniform half _UseBassIntensity;
uniform half _ALSoundHue;
//VRSL Stuffs
uniform int _DMXGroup;
//Both
uniform float _OutlineWidth;
//Other
uniform float _SpaceyScaling;
uniform int _Invisibility;
uniform half _EmissionStrength;
uniform float _AddLightIntensity;
uniform float _MinAmbient;

#endif

#ifndef BIGI_DEFAULT_FRAGOUT
#define BIGI_DEFAULT_FRAGOUT

struct fragOutput {
    fixed4 color : SV_Target;
};
#endif

#ifndef BIGI_EPSILON
#define BIGI_EPSILON
#include <UnityCG.cginc>
#define Epsilon UNITY_HALF_MIN
#endif

#endif
