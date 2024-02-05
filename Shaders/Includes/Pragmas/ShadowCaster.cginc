#ifndef BIGI_SHADOWCASTER_PRAGMA
#define BIGI_SHADOWCASTER_PRAGMA

#include_with_pragmas "./Global.cginc"

#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma multi_compile_instancing
#pragma multi_compile_shadowcaster
#pragma multi_compile_fog

#endif