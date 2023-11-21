#ifndef BIGI_SOUND_UTILS_DEFINES
#define BIGI_SOUND_UTILS_DEFINES
#include "./BigiSoundUtils.cginc"
#include "./BigiShaderParams.cginc"



#define GET_SOUND_SETTINGS(set) b_sound::ALSettings set; \
set.AL_Theme_Weight = _AL_Theme_Weight; \
set.AL_Hue_Weight = _AL_Hue_Weight; \
set.AL_Hue = _AL_Hue; \
set.AL_Hue_BassReactive = _AL_Hue_BassReactive; \
set.AL_TC_BassReactive = _AL_TC_BassReactive;

#define GET_SOUND_COLOR_CALL(setin,lout) half4 lout = b_sound::GetDMXOrALColor(setin);

#define GET_SOUND_COLOR(outName) b_sound::ALSettings set; \
set.AL_Theme_Weight = _AL_Theme_Weight; \
set.AL_Hue_Weight = _AL_Hue_Weight; \
set.AL_Hue = _AL_Hue; \
set.AL_Hue_BassReactive = _AL_Hue_BassReactive; \
set.AL_TC_BassReactive = _AL_TC_BassReactive; \
const half4 outName = b_sound::GetDMXOrALColor(set);

#endif
