#ifndef BIGI_SOUND_UTILS_INCLUDE
#define BIGI_SOUND_UTILS_INCLUDE


#ifndef BIGI_DMXAL_INCLUDES
#define BIGI_DMXAL_INCLUDES
#include "./AudioLink.cginc"
#include "./VRSL-DMXAvatarFunctions.cginc"
#endif

namespace b_sound {



    half GetScaleFactor(half al_tresh){
        return al_tresh*2.0;
    }

    half4 Scale(half4 c, half factor){
        return pow(c,0.3) * GetScaleFactor(factor);
    }

    //Audiolink COLOR Selection (ccI)
    const uint OLD_STYLE = 0u;
    const uint TC_1 = 1u;
    const uint TC_2 = 2u;
    const uint TC_3 = 3u;
    const uint TC_4 = 4u;

    const half NO_CHANGES = 0.0;
    const half BASS_ACTIVE = 1.0;

    half4 GetSoundColor(uint ccI, half ccM, half factor){
        uint2 fal = ALPASS_FILTEREDAUDIOLINK + uint2(15,0);
        switch(ccI){
            case 0u: 
                return Scale(half4(
                    AudioLinkData(fal+uint2(0,3)).r,
                    (AudioLinkData(fal+uint2(0,1)).r/2.0) + (AudioLinkData(fal+uint2(0,2)).r/2.0),
                    AudioLinkData(fal+uint2(0,0)).r,
                    1.0
                ),factor);
            case 1u:
            case 2u:
            case 3u:
            case 4u:
                float mult = Scale(1.0 - ccM,factor) + (Scale((AudioLinkData(fal)+AudioLinkData(fal+uint2(0,1))),factor) * ccM);
                return AudioLinkData(ALPASS_THEME_COLOR0 + uint2(clamp(ccI - 1,0,3),0)) * float4(mult,mult,mult,1.0);
                break;
            default:
                return half4(0,0,0,1);
        }
    }

    struct DMXInfo {
        half Intensity;
        half3 ResultColor;
    };
    DMXInfo GetDMXInfo(uint group){
        DMXInfo ret;
        switch(group){
            case 1u:
            case 2u:
            case 3u:
            case 4u:
                ret.Intensity = clamp(GetDMXIntensity(group)-0.5,0.0,0.5)*2.0;
                ret.ResultColor = GetDMXColor(group).rgb * ret.Intensity;
                return ret;
            case 0u:
            default:
                ret.Intensity = 0.0;
                ret.ResultColor = 0.0;
                return ret;
        }
    }

}
#endif