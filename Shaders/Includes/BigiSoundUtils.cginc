#ifndef BIGI_SOUND_UTILS_INCLUDE
#define BIGI_SOUND_UTILS_INCLUDE


#ifndef BIGI_DMXAL_INCLUDES
#define BIGI_DMXAL_INCLUDES
#ifdef EXTERNAL_AUDIOLINK_ON
#include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"
#else
#include "./Includes/AudioLink_0.3.1.cginc"
#endif
#include <UnityCG.cginc>
#include "./VRSL-DMXAvatarFunctions.cginc"
#endif
#include "./ColorUtil.cginc"

namespace b_sound
{
    half GetScaleFactor(const half factor) { return factor * 2.0; }

    half4 Scale(const half4 color, const half factor) { return pow(color, 0.3) * GetScaleFactor(factor); }

    struct ALSettings {
        float DMX_Weight;
        float AL_Theme_Weight;
        float AL_Hue_Weight;

        uint AL_ThemeIndex; // Audiolink index (0-3)
        uint DMX_Group; // DMX group for VRSL (mostly 2, 1-4)
        half AL_Hue; // HSV Hue for a stable bassreactive color

        half AL_Hue_BassReactive; //bool for bass reactivity of the AL_Hue
        half AL_TC_BassReactive; //bool for bass reactivity of the AL_Theme
    };

    struct MixRatio {
        float totalWeight;
        half3 totalColor;
    };

    void doMixProperly(inout MixRatio obj, in const half3 color, in const float weight)
    {
        obj.totalWeight += weight;
        obj.totalColor = lerp(obj.totalColor, color, weight / (obj.totalWeight + Epsilon));
    }

    half4 GetDMXOrALColor(in const ALSettings conf)
    {
        MixRatio mix;
        mix.totalColor = 0;
        mix.totalWeight = 0;
        //DMX
        {
            if (conf.DMX_Weight > Epsilon) {
                const float intensity = clamp(GetDMXIntensity(conf.DMX_Group) - 0.5, 0.0, 0.5) * 2.0;
                const float3 color = GetDMXColor(conf.DMX_Group).rgb;
                doMixProperly(mix, color, intensity * conf.DMX_Weight);
            }
        }
        const uint2 cord = ALPASS_FILTEREDAUDIOLINK + uint2(15, 0);
        const float bassIntensity = AudioLinkData(cord).r;
        //AL Theme
        {
            if (conf.AL_Theme_Weight > Epsilon) {
                const uint2 tcord = ALPASS_THEME_COLOR0 + uint2(conf.AL_ThemeIndex, 0);
                float4 color = AudioLinkData(tcord);
                const float soundIntensity = (bassIntensity * conf.AL_TC_BassReactive) + (1.0 - conf.AL_TC_BassReactive);
                doMixProperly(mix, color.rgb, color.a * conf.AL_Theme_Weight * soundIntensity);
            }
        }
        //HueSlider
        {
            if (conf.AL_Hue_Weight > Epsilon) {
                const float soundIntensity = (bassIntensity * conf.AL_Hue_BassReactive) + (1.0 - conf.AL_Hue_BassReactive);
                const float3 color = HSVToRGB(conf.AL_Hue, 1.0, 1.0);
                doMixProperly(mix, color, soundIntensity * conf.AL_Hue_Weight);
            }
        }
        return half4(mix.totalColor, mix.totalWeight / (conf.DMX_Weight + conf.AL_Hue_Weight + conf.AL_Theme_Weight + Epsilon));
    }

    half4 GetThemeColor(const uint ccindex)
    {
        return AudioLinkData(ALPASS_THEME_COLOR0 + uint2(ccindex, 0));
    }

    float GetTime() { return AudioLinkGetChronoTime(0, 0) % 2.0f / 2.0f; }
}
#endif
