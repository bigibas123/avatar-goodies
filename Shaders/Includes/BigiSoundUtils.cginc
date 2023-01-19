#ifndef BIGI_SOUND_UTILS_INCLUDE
#define BIGI_SOUND_UTILS_INCLUDE


#ifndef BIGI_DMXAL_INCLUDES
#define BIGI_DMXAL_INCLUDES
#ifdef EXTERNAL_AUDIOLINK_ON
#include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"
#else
#include "./Includes/AudioLink_0.3.1.cginc"
#endif
#include "./VRSL-DMXAvatarFunctions.cginc"
#endif
#include "./ColorUtil.cginc"

namespace b_sound
{
    half GetScaleFactor(const half factor) { return factor * 2.0; }

    half4 Scale(const half4 color, const half factor) { return pow(color, 0.3) * GetScaleFactor(factor); }

    half4 GetSoundColor(const uint colorChordIndex, const half bassReactive, const half factor, half cc0Hue)
    {
        uint2 fal = ALPASS_FILTEREDAUDIOLINK + uint2(15, 0);
        half4 ret;
        if (colorChordIndex == 0u) {
            const half3 color = HSVToRGB(half3(cc0Hue,1.0,1.0));
            const float sound = Scale(AudioLinkData(fal) + AudioLinkData(fal+uint2(0,1)),factor).r;
            ret = half4(sound * color,1.0);
        } else if (colorChordIndex <= 4u) {
            const uint2 sCord = ALPASS_THEME_COLOR0 + uint2(clamp(colorChordIndex - 1, 0, 3), 0);
            float mult = Scale(1.0 - bassReactive, factor) + (Scale((AudioLinkData(fal) + AudioLinkData(fal+uint2(0,1))), factor) * bassReactive);
            ret = AudioLinkData(sCord) * float4(mult, mult, mult, 1.0);
        } else { ret = half4(0, 0, 0, 1); }
        return clamp(ret, 0, 1);
    }
    
    half4 GetSoundColor(const uint colorChordIndex, const half bassReactive, const half factor)
    {
        uint2 fal = ALPASS_FILTEREDAUDIOLINK + uint2(15, 0);
        half4 ret;
        if (colorChordIndex == 0u) {
            ret = Scale(
                half4(
                    AudioLinkData(fal+uint2(0,3)).r, (AudioLinkData(fal+uint2(0,1)).r / 2.0) + (AudioLinkData(fal+uint2(0,2)).r / 2.0),
                    AudioLinkData(fal+uint2(0,0)).r, 1.0
                ), factor
            );
        } else if (colorChordIndex <= 4u) {
            const uint2 sCord = ALPASS_THEME_COLOR0 + uint2(clamp(colorChordIndex - 1, 0, 3), 0);
            float mult = Scale(1.0 - bassReactive, factor) + (Scale((AudioLinkData(fal) + AudioLinkData(fal+uint2(0,1))), factor) * bassReactive);
            ret = AudioLinkData(sCord) * float4(mult, mult, mult, 1.0);
        } else { ret = half4(0, 0, 0, 1); }
        return clamp(ret, 0, 1);
    }

    struct dmx_info {
        half Intensity;
        half3 ResultColor;
    };

    dmx_info GetDMXInfo(const uint group)
    {
        dmx_info ret;
        if (group > 0u) {
            ret.Intensity = clamp(GetDMXIntensity(group) - 0.5, 0.0, 0.5) * 2.0;
            ret.ResultColor = GetDMXColor(group).rgb * ret.Intensity;
        } else {
            ret.Intensity = 0.0;
            ret.ResultColor = 0.0;
        }
        return ret;
    }

    
    float GetTime()
    {
        return AudioLinkGetChronoTime(0, 0) % 2.0f / 2.0f;
    }
}
#endif
