#ifndef BIGI_SOUND_UTILS
#define BIGI_SOUND_UTILS

#ifndef BIGI_DMXAL_INCLUDES
#define BIGI_DMXAL_INCLUDES
#include <UnityCG.cginc>
#include <Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc>
#include "./BigiVRSL.cginc"
#include "./ColorUtil.cginc"
#endif

namespace b_sound
{
	struct ALSettings
	{
		float AL_Theme_Weight;
		half AL_TC_BassReactive; //bool for bass reactivity of the AL_Theme
	};

	struct MixRatio
	{
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
			if (conf.AL_Theme_Weight > Epsilon)
			{
				float4 color1 = AudioLinkData(ALPASS_THEME_COLOR0);
				float4 color2 = AudioLinkData(ALPASS_THEME_COLOR1);
				float4 color3 = AudioLinkData(ALPASS_THEME_COLOR2);
				float4 color4 = AudioLinkData(ALPASS_THEME_COLOR3);
				float4 intensities = float4(RGBToHSV(color1.rgb * color1.a).z, RGBToHSV(color2.rgb * color2.a).z,
											RGBToHSV(color3.rgb * color3.a).z, RGBToHSV(color4.rgb * color4.a).z);

				float4 finalColor;
				/*if (intensities.w > Epsilon)
				{
					finalColor = color4;
				}
				else if (intensities.z > Epsilon)
				{
					finalColor = color3;
				}
				else*/ if (intensities.y > Epsilon)
				{
					finalColor = color2;
				}
				else if (intensities.x > Epsilon)
				{
					finalColor = color1;
				}
				else
				{
					finalColor = float4(0, 0, 0, 0);
				}
				const float soundIntensity = clamp(lerp(1.0, bassIntensity, conf.AL_TC_BassReactive), 0.0, 1.0);
				doMixProperly(mix, finalColor.rgb, soundIntensity * conf.AL_Theme_Weight);
			}
		}
		return half4(mix.totalColor, mix.totalWeight / (conf.AL_Theme_Weight + Epsilon));
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

	/*
	Strange way of getting an autdiolink value, x [0,1] for how long ago y [0,3] for the band
	*/
	float GetAudioLink(float x)
	{
		float totalValue = 0;
		totalValue += AudioLinkLerp(ALPASS_AUDIOLINK + float2(((x * 1.0) % 1) * AUDIOLINK_WIDTH, 0)).r;
		// totalValue += AudioLinkLerp(ALPASS_AUDIOLINK + float2(((x * 2.0) % 1) * AUDIOLINK_WIDTH, 1)).r;
		// totalValue += AudioLinkLerp(ALPASS_AUDIOLINK + float2(((x * 4.0) % 1) * AUDIOLINK_WIDTH, 2)).r;
		// totalValue += AudioLinkLerp(ALPASS_AUDIOLINK + float2(((x * 8.0) % 1) * AUDIOLINK_WIDTH, 3)).r;
		
		return totalValue;
	}

	float GetAutoCorrelator(float x)
	{
		return AudioLinkLerp( ALPASS_AUTOCORRELATOR + float2( x * AUDIOLINK_WIDTH, 0 ) ).r;
	}

	float GetWaves(in float distance)
	{
		distance = distance % 1.0;
		return (GetAudioLink(distance) * 2.5) + Epsilon;//+ (GetAutoCorrelator(distance * 10.0) * 2.5) + 1.0;
	}
}
#endif
