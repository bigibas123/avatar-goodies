#ifndef BIGI_FORWARD_BASE_PRAGMA
#define BIGI_FORWARD_BASE_PRAGMA

#include_with_pragmas "./Global.cginc"

#pragma multi_compile_fwdbase
#pragma multi_compile_fragment _ VERTEXLIGHT_ON  //UNITY!!!!!!! https://forum.unity.com/threads/vertexlight_on-always-undefined-in-fragment-shader.284781/ // already defined in vertex by multi_compile_fwdbase 

//#pragma multi_compile_shadowcollector


#endif