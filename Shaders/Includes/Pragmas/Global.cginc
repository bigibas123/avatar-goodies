#ifndef BIGI_GLOBAL_PRAGMA
#define BIGI_GLOBAL_PRAGMA
#pragma target 5.0

//#pragma warning(disable : 3568)
//#pragma enable_d3d11_debug_symbols

//#pragma multi_compile_instancing
//#pragma instancing_options assumeuniformscaling
//#pragma multi_compile_fog


#pragma shader_feature_local MULTI_TEXTURE
#pragma shader_feature_local DO_ALPHA_PLS
#pragma shader_feature_local NORMAL_MAPPING


#pragma skip_variants LIGHTMAP_ON DYNAMICLIGHTMAP_ON LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK DIRLIGHTMAP_COMBINED _MIXED_LIGHTING_SUBTRACTIVE

#endif