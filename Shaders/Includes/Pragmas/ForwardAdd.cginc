#pragma once

#include_with_pragmas "./Global.cginc"

#pragma multi_compile_fwdadd
#pragma multi_compile_fwdadd_fullshadows
#pragma multi_compile_shadowcollector
#pragma multi_compile_lightpass

#pragma shader_feature VERTEXLIGHT_ON //UNITY!!!!!!! https://forum.unity.com/threads/vertexlight_on-always-undefined-in-fragment-shader.284781/
