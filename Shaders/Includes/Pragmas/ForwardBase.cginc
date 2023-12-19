#ifndef BIGI_FORWARD_BASE_PRAGMA
#define BIGI_FORWARD_BASE_PRAGMA

#include_with_pragmas "./Global.cginc"

#pragma multi_compile_fwdbase
#pragma multi_compile_fwdbasealpha
#pragma multi_compile_shadowcollector
#pragma multi_compile_lightpass

#pragma multi_compile VERTEXLIGHT_ON //UNITY!!!!!!! https://forum.unity.com/threads/vertexlight_on-always-undefined-in-fragment-shader.284781/

#endif