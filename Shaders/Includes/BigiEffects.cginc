#ifndef BIGI_EFFECTS_INCLUDE
#define BIGI_EFFECTS_INCLUDE
#include <HLSLSupport.cginc>
#include "./ColorUtil.cginc"

namespace b_effects
{
    fixed4 Monochromize(fixed4 input, float enabled)
    {
        half colorValue = RGBToHSV(input.rgb * input.a).z;
        //colorValue = smoothstep(0.4,0.6,colorValue);
        fixed4 ret = fixed4(colorValue,colorValue,colorValue,input.a);
        return lerp(input,ret,enabled);
    }
}

#endif
