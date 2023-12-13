#pragma once

#ifndef BIGI_DMXAL_INCLUDES
#define BIGI_DMXAL_INCLUDES
#include <UnityCG.cginc>
#include <Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc>
#include "./BigiVRSL.cginc"
#include "./ColorUtil.cginc"
#endif

namespace b_sound
{

    struct ALSettings {
        float AL_Theme_Weight;
        float AL_Hue_Weight;
        
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
        const uint2 cord = ALPASS_FILTEREDAUDIOLINK + uint2(5, 0);
        const float bassIntensity = AudioLinkData(cord).r;
        //AL Theme
        {
            if (conf.AL_Theme_Weight > Epsilon) {
                float4 color1 = AudioLinkData(ALPASS_THEME_COLOR0);
                float4 color2 = AudioLinkData(ALPASS_THEME_COLOR1);
                float4 color3 = AudioLinkData(ALPASS_THEME_COLOR2);
                float4 color4 = AudioLinkData(ALPASS_THEME_COLOR3);
                float4 intensities = float4(RGBToHSV(color1.rgb * color1.a).z, RGBToHSV(color2.rgb * color2.a).z, RGBToHSV(color3.rgb * color3.a).z, RGBToHSV(color4.rgb * color4.a).z);

                float4 finalColor;
                if (intensities.w > Epsilon) {
                    finalColor = color4;
                } else if (intensities.z > Epsilon) {
                    finalColor = color3;
                } else if (intensities.y > Epsilon) {
                    finalColor = color2;
                } else if (intensities.x > Epsilon) {
                    finalColor = color1;
                } else {
                    finalColor = float4(0, 0, 0, 0);
                }
                const float soundIntensity = clamp(lerp(1.0,bassIntensity,conf.AL_TC_BassReactive),0.0,1.0);
                doMixProperly(mix, finalColor.rgb, soundIntensity * conf.AL_Theme_Weight);
            }
        }
        //HueSlider
        {
            if (conf.AL_Hue_Weight > Epsilon) {
                const float3 color = HSVToRGB(conf.AL_Hue, 1.0, 1.0);
                const float soundIntensity = clamp(lerp(1.0,bassIntensity,conf.AL_Hue_BassReactive),0.0,1.0);
                doMixProperly(mix, color, soundIntensity * conf.AL_Hue_Weight);
            }
        }
        return half4(mix.totalColor, mix.totalWeight / (conf.AL_Hue_Weight + conf.AL_Theme_Weight + Epsilon));
    }

    half4 GetThemeColor(const uint ccindex)
    {
        return AudioLinkData(ALPASS_THEME_COLOR0 + uint2(ccindex, 0));
    }

    float GetTime()
    {
        return AudioLinkGetChronoTime(0, 0) % 2.0f / 2.0f;
    }

    float GetTimeRaw()
    {
        return AudioLinkGetChronoTime(0, 0);
    }
}

