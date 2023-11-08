Shader "Bigi/Rounding"
{
    Properties
    {

        [MainTexture] _MainTex ("Texture", 2D) = "black" {}
        [NoScaleOffset] _OcclusionMap ("Ambient occlusion map", 2D) = "white" {}
        [NoScaleOffset] _BumpMap("Normal Map", 2D) = "bump" {}
        
        _AddLightIntensity ("Additive lighting intensity", Range(0.0,2.0)) = 1.0
        _MinAmbient ("Minimum ambient intensity", Range(0.0,1.0)) = 0.005
        _LightDiffuseness ("Shadow Diffuseness",Range(0.0,1.0)) = 0.1
        
        _RoundFactor ("Round factor Higher is more precise", Range(0.0,1000.0)) = 100.0
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags
        {
            "RenderType" = "Opaque" "Queue" = "Geometry" "VRCFallback" = "ToonCutout"
        }
        
        CGINCLUDE
        #include "./Includes/ToonVert.cginc"
        float _RoundFactor;
            v2f vert(appdata v)
            {
                v2f ret = bigi_toon_vert(v);
                ret.pos.x = round(ret.pos.x * _RoundFactor) / _RoundFactor;
                ret.pos.y = round(ret.pos.y * _RoundFactor) / _RoundFactor;
                return ret;
            }
        ENDCG

        LOD 100
        Pass
        {
            Name "OpaqueForwardBase"
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            Cull Off
            ZWrite On
            ZTest LEqual
            Blend One OneMinusSrcAlpha
            Stencil
            {
                Ref 1
                Comp Always
                WriteMask 1
                Pass Replace
            }
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma instancing_options assumeuniformscaling
            #pragma multi_compile_instancing
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fwdbasealpha
            #pragma multi_compile_lightpass
            #pragma multi_compile_shadowcollector
            #pragma multi_compile_fog
            #pragma multi_compile_local __ MULTI_TEXTURE

            #include "./Includes/BigiShaderParams.cginc"
            #include "./Includes/ToonVert.cginc"
            #include "./Includes/LightUtilsDefines.cginc"
            #include "./Includes/NormalUtils.cginc"

            #include "./Includes/BigiEffects.cginc"

            fragOutput frag(v2f i)
            {
                const fixed4 orig_color = GET_TEX_COLOR(i.uv);
                clip(orig_color.a - 1.0);
                fragOutput o;
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                i.normal = b_normalutils::recalculate_normals(i.normal, GET_NORMAL(i.uv), i.tangent, i.bitangent);

                BIGI_GETLIGHT_DEFAULT(lighting);
                o.color = orig_color * lighting
                UNITY_APPLY_FOG(i.fogCoord, o.color);
                return o;
            }
            ENDCG
        }

        Pass
        {
            Name "TransparentForwardBase"
            Tags
            {
                "RenderType" = "Transparent" "Queue" = "Transparent"
            }
            Cull Off
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            Stencil
            {
                Ref 2
                Comp Always
                WriteMask 2
                Pass Replace
            }
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma instancing_options assumeuniformscaling
            #pragma multi_compile_instancing
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fwdbasealpha
            #pragma multi_compile_lightpass
            #pragma multi_compile_shadowcollector
            #pragma multi_compile_fog
            #pragma multi_compile_local __ MULTI_TEXTURE

            #include "./Includes/BigiShaderParams.cginc"
            #include "./Includes/ToonVert.cginc"
            #undef VERTEXLIGHT_ON
            #include "./Includes/LightUtilsDefines.cginc"
            #include "./Includes/NormalUtils.cginc"
            #include "./Includes/BigiEffects.cginc"
            
            
            fragOutput frag(v2f i)
            {
                const fixed4 orig_color = GET_TEX_COLOR(i.uv);
                clip((-1.0 * (orig_color.a - 1.0)) - Epsilon);
                fragOutput o;
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                i.normal = b_normalutils::recalculate_normals(i.normal, GET_NORMAL(i.uv), i.tangent, i.bitangent);

                BIGI_GETLIGHT_DEFAULT(lighting);
                
                o.color = orig_color * lighting;
                UNITY_APPLY_FOG(i.fogCoord, o.color);

                return o;
            }
            ENDCG
        }

        Pass
        {
            Name "ForwardAdd"
            Tags
            {
                "LightMode" = "ForwardAdd"
            }
            Cull Off
            ZWrite Off
            ZTest LEqual
            Blend One One
            Stencil
            {
                Ref 4
                Comp Always
                WriteMask 4
                Pass Replace
            }
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma instancing_options assumeuniformscaling
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_lightpass
            #pragma multi_compile_shadowcollector
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile_local __ MULTI_TEXTURE

            #include "./Includes/ToonVert.cginc"
            #include "./Includes/LightUtilsDefines.cginc"
            #include "./Includes/BigiEffects.cginc"
            #include "./Includes/NormalUtils.cginc"

            fragOutput frag(v2f i)
            {
                clip(_AddLightIntensity - Epsilon);

                fragOutput o;
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                i.normal = b_normalutils::recalculate_normals(i.normal, GET_NORMAL(i.uv), i.tangent, i.bitangent);

                BIGI_GETLIGHT_DEFAULT(lighting);

                const fixed4 orig_color = GET_TEX_COLOR(i.uv);

                const fixed4 mask = GET_MASK_COLOR(i.uv);
                o.color = orig_color*lighting;
                UNITY_APPLY_FOG(i.fogCoord, o.color);
                o.color = o.color * _AddLightIntensity;
                return o;
            }
            ENDCG
        }

        //UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 2.0

            #pragma multi_compile_shadowcaster

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #include "UnityStandardShadow.cginc"
            ENDCG
        }
    }
}