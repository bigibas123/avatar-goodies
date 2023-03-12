#ifndef BIGI_V1_SHADERPARAMS
#define BIGI_V1_SHADERPARAMS


#ifndef BIGI_V1_TEXTURES
#define BIGI_V1_TEXTURES
#include <HLSLSupport.cginc>
UNITY_DECLARE_TEX2D(_MainTex);
float4 _MainTex_ST;
UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask);
UNITY_DECLARE_TEX2D_NOSAMPLER(_AOMap);
UNITY_DECLARE_TEX2D(_Spacey);
float4 _Spacey_ST;
#endif

#ifndef BIGI_V1_UNIFORMS
#define BIGI_V1_UNIFORMS

uniform float _DMX_Weight;
uniform float _AL_Theme_Weight;
uniform float _AL_Hue_Weight;

uniform uint _AL_ThemeIndex;
uniform uint _DMX_Group;
uniform half _AL_Hue;

uniform half _AL_Hue_BassReactive;
uniform half _AL_TC_BassReactive;

//Both
uniform float _OutlineWidth;
//Other
uniform half _EmissionStrength;
uniform float _AddLightIntensity;
uniform float _MinAmbient;
//Effects
uniform float _MonoChrome;

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
