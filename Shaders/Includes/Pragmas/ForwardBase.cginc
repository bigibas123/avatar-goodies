#ifndef BIGI_FORWARD_BASE_PRAGMA
#define BIGI_FORWARD_BASE_PRAGMA

#include_with_pragmas "./Global.cginc"

//#pragma multi_compile_fwdbase
#pragma multi_compile DIRECTIONAL VERTEXLIGHT_ON LIGHTPROBE_SH SHADOWS_SCREEN SHADOWS_SHADOWMASK
#pragma multi_compile_instancing
#pragma multi_compile _ VERTEXLIGHT_ON


#endif