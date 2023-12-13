#pragma once

#include "./BigiShaderTextures.cginc"

//#include <UnityShaderVariables.cginc>

#ifndef BIGI_UNIFORMS
#define BIGI_UNIFORMS

#ifndef BIGI_UNIFORMS_DMXAL
#define BIGI_UNIFORMS_DMXAL

uniform float _DMX_Weight;
uniform float _AL_Theme_Weight;
uniform float _AL_Hue_Weight;

uniform uint _DMX_Group;
uniform half _AL_Hue;

uniform half _AL_Hue_BassReactive;
uniform half _AL_TC_BassReactive;

//Both
uniform float _OutlineWidth;

#endif


#ifndef BIGI_UNIFORMS_LIGHTING
#define BIGI_UNIFORMS_LIGHTING
//Other
uniform half _EmissionStrength;
uniform float _AddLightIntensity;
uniform float _VertLightIntensity;
uniform float _MinAmbient;

//Effects
uniform float _MonoChrome;
uniform float _Voronoi;
uniform float _LightDiffuseness;

#endif


#ifndef BIGI_DEFAULT_FRAGOUT
#define BIGI_DEFAULT_FRAGOUT

#include <HLSLSupport.cginc>

struct fragOutput {
    fixed4 color : SV_Target;
};
#endif

#ifndef Epsilon
#include <UnityCG.cginc>
#define Epsilon UNITY_HALF_MIN
#endif

#endif
