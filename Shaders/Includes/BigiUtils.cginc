#ifndef BIGI_UTILS_INCLUDE
#define BIGI_UTILS_INCLUDE


#ifndef BIGI_DMXAL_INCLUDES
#define BIGI_DMXAL_INCLUDES
#include "./AudioLink.cginc"
#include "./VRSL-DMXAvatarFunctions.cginc"
#endif

namespace Bigi {
    //Audiolink COLOR Selection
    const uint OLD_STYLE = 0u;
    const uint TC_1 = 1u;
    const uint TC_2 = 2u;
    const uint TC_3 = 3u;
    const uint TC_4 = 4u;

    //Audiolink Theme color scaling via bass or just the color
    const bool TC_THEME = true;
    const bool TC_CC = false;

    half4 GetSoundColor(uint ccI, bool ccM){
        switch(ccI){
            case 0u:
                uint2 fal = ALPASS_FILTEREDAUDIOLINK + uint2(15,0);
                return half4(
                    AudioLinkData(fal+uint2(0,3)).r,
                    (AudioLinkData(fal+uint2(0,1)).r/2.0) + (AudioLinkData(fal+uint2(0,2)).r/2.0),
                    AudioLinkData(fal+uint2(0,0)).r,
                    1.0
                );
            case 1u:
            case 2u:
            case 3u:
            case 4u:
                return AudioLinkData(ALPASS_THEME_COLOR0 + uint2(clamp(ccI - 1,0,3),0)) * (ccM ? AudioLinkData(ALPASS_FILTEREDAUDIOLINK + uint2(15,0)).r : 1);
                break;
            default:
                return half4(0,0,0,1);
        }
    }

    half GetScaleFactor(half al_tresh){
        return clamp(al_tresh*2.0,0.0,2.0);
    }

    half4 Scale(half4 c, half factor){
        return c * GetScaleFactor(factor);
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
                ret.Intensity = clamp(GetDMXIntensity(_DMXGroup)-0.5,0.0,0.5)*2.0;
                ret.ResultColor = GetDMXColor(_DMXGroup).rgb * ret.Intensity;
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