Shader "Bigi/AudioLink_frag"
{
    Properties
    {

        [MainTexture] _MainTex ("Texture", 2D) = "black" {}
        _Spacey ("Spacey Texture", 2D) = "black" {}
        _EmissionStrength ("Emission strength", Range(0.0,2.0)) = 1.0
        [NoScaleOffset] _Mask ("Mask", 2D) = "black" {}
        [NoScaleOffset] _AOMap ("Ambient occlusion map", 2D) = "white" {}
        [NoScaleOffset] _NormalMap("Normal Map", 2D) = "bump" {}

        _OutlineWidth ("Outline Width", Range(0.0,1.0)) = 0.0
        _AddLightIntensity ("Additive lighting intensity", Range(0.0,1.0)) = 0.1
        _MinAmbient ("Minimum ambient intensity", Range(0.0,1.0)) = 0.005

        [Header(Audiolink world theme colors)]
        _AL_Theme_Weight("Weight", Range(0.0, 1.0)) = 0.0
        _AL_TC_BassReactive("Bassreactivity", Range(0.0,1.0)) = 0.0

        [Header(Audiolink Hue slider colors)]
        _AL_Hue_Weight("Weight", Range(0.0,1.0)) = 0.0
        _AL_Hue("Hue", Range(0.0,1.0)) = 0.0
        _AL_Hue_BassReactive("Bassreactiviy", Range(0.0,1.0)) = 0.0

        [Header(Effects)]
        _MonoChrome("MonoChrome", Range(0.0,1.0)) = 0.0
        _Voronoi("Voronoi", Range(0.0,1.0)) = 0.0

        [Header(Effects)]
        [Toggle(MULTI_TEXTURE)] _MultiTexture("Use multi texture", Float) = 0
        _MainTexArray ("Other textures", 2DArray) = "" {}
        _OtherTextureId ("Other texture Id", Int) = 0

    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha

        LOD 100

        Pass
        {
            Name "OpaqueForwardBase"
            Tags
            {
                "RenderType" = "Opaque" "Queue" = "Geometry" "VRCFallback"="ToonCutout" "LightMode" = "ForwardBase"
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
            #pragma multi_compile __ MULTI_TEXTURE

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
                
                i.normal = b_normalutils::recalc_normals(i.normal, GET_NORMAL(i.uv), i.tangent, i.bitangent);

                BIGI_GETLIGHT_DEFAULT(lighting);


                const fixed4 mask = GET_MASK_COLOR(i.uv);
                o.color = b_effects::apply_effects(i.uv, mask, orig_color, lighting, i.staticTexturePos);
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
                "RenderType" = "TransparentCutout" "Queue" = "AlphaTest" "LightMode" = "ForwardBase" "VRCFallback"="ToonCutout"
            }
            Cull Off
            ZWrite On
            ZTest LEqual
            Blend One OneMinusSrcAlpha
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
            #pragma multi_compile __ MULTI_TEXTURE

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

                i.normal = b_normalutils::recalc_normals(i.normal, GET_NORMAL(i.uv), i.tangent, i.bitangent);
                
                BIGI_GETLIGHT_DEFAULT(lighting);

                const fixed4 mask = GET_MASK_COLOR(i.uv);
                o.color = b_effects::apply_effects(i.uv, mask, orig_color, lighting, i.staticTexturePos);
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
                "LightMode" = "ForwardAdd" "Queue" = "TransparentCutout"
            }
            Cull Back
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
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_lightpass
            #pragma multi_compile_shadowcollector
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile __ MULTI_TEXTURE

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
                
                i.normal = b_normalutils::recalc_normals(i.normal, GET_NORMAL(i.uv), i.tangent, i.bitangent);
                
                BIGI_GETLIGHT_DEFAULT(lighting);

                const fixed4 orig_color = GET_TEX_COLOR(i.uv);

                const fixed4 mask = GET_MASK_COLOR(i.uv);
                o.color = b_effects::apply_effects(i.uv, mask, orig_color, lighting * _AddLightIntensity, i.staticTexturePos);
                UNITY_APPLY_FOG(i.fogCoord, o.color);
                return o;
            }
            ENDCG
        }


        Pass
        {
            Name "Outline"
            Tags
            {
                "RenderType" = "TransparentCutout" "Queue" = "Transparent+-1"
            }
            Cull Off
            ZWrite On
            ZTest LEqual
            Stencil
            {
                Ref 0
                ReadMask 7
                WriteMask 0
                Comp GEqual
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
            #pragma multi_compile __ MULTI_TEXTURE

            #include "./Includes/SoundUtilsDefines.cginc"


            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID };

            //intermediate
            struct v2f {
                UNITY_POSITION(pos); //float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID UNITY_VERTEX_OUTPUT_STEREO };

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                float3 offset = v.normal.xyz * (_OutlineWidth * 0.01);
                o.pos = UnityObjectToClipPos(v.vertex + offset);
                return o;
            }

            fragOutput frag(v2f i)
            {
                clip(_OutlineWidth - Epsilon);
                fragOutput o;
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                GET_SOUND_COLOR(scol);
                o.color = scol;
                return o;
            }
            ENDCG

        }

        //UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        Pass
        {
            Name "ShadowPass"
            Tags
            {
                "LightMode"="ShadowCaster"
            }
            Cull Off
            ZWrite On
            ZTest LEqual
            Stencil
            {
                Comp Always
                Pass IncrSat
            }
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert alpha
            #pragma fragment frag alpha
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            #pragma multi_compile_lightpass
            #pragma instancing_options assumeuniformscaling
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fwdbasealpha
            #pragma multi_compile_lightpass
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            uniform int _Invisibility;

            struct v2f {
                V2F_SHADOW_CASTER;
                UNITY_VERTEX_INPUT_INSTANCE_ID UNITY_VERTEX_OUTPUT_STEREO
                //float4 uv : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                //o.uv = v.texcoord;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                clip(-1 * _Invisibility);
                UNITY_SETUP_INSTANCE_ID(i) UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i) SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}