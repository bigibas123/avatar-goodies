#ifndef BIGI_SOUND_UTILS_DEFINES
#define BIGI_SOUND_UTILS_DEFINES
#include "./BigiSoundUtils.cginc"
#include "./BigiShaderParams.cginc"



#define GET_SOUND_SETTINGS(outName) b_sound::ALSettings set; \
set.DMX_Weight = _DMX_Weight; \
set.AL_Theme_Weight = _AL_Theme_Weight; \
set.AL_Hue_Weight = _AL_Hue_Weight; \
set.AL_ThemeIndex = _AL_ThemeIndex; \
set.DMX_Group = _DMX_Group; \
set.AL_Hue = _AL_Hue; \
set.AL_Hue_BassReactive = _AL_Hue_BassReactive; \
set.AL_TC_BassReactive = _AL_TC_BassReactive;

#define GET_SOUND_COLOR_CALL(setin,lout) half4 lout = b_sound::GetDMXOrALColor(setin);

#define GET_SOUND_COLOR(outName) b_sound::ALSettings set; \
set.DMX_Weight = _DMX_Weight; \
set.AL_Theme_Weight = _AL_Theme_Weight; \
set.AL_Hue_Weight = _AL_Hue_Weight; \
set.AL_ThemeIndex = _AL_ThemeIndex; \
set.DMX_Group = _DMX_Group; \
set.AL_Hue = _AL_Hue; \
set.AL_Hue_BassReactive = _AL_Hue_BassReactive; \
set.AL_TC_BassReactive = _AL_TC_BassReactive; \
half4 outName = b_sound::GetDMXOrALColor(set);

#endif
