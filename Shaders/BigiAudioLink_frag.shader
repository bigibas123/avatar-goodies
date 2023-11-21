Shader "Bigi/AudioLink_frag"
{
    Properties
    {

        [MainTexture] _MainTex ("Texture", 2D) = "black" {}
        _Spacey ("Spacey Texture", 2D) = "black" {}
        _EmissionStrength ("Emission strength", Range(0.0,2.0)) = 1.0
        [NoScaleOffset] _Mask ("Mask", 2D) = "black" {}
        [NoScaleOffset] _OcclusionMap ("Ambient occlusion map", 2D) = "white" {}
        [NoScaleOffset] _BumpMap("Normal Map", 2D) = "bump" {}

        _OutlineWidth ("Outline Width", Range(0.0,1.0)) = 0.0
        _AddLightIntensity ("Additive lighting intensity", Range(0.0,2.0)) = 1.0
        _MinAmbient ("Minimum ambient intensity", Range(0.0,1.0)) = 0.005

        [Header(Audiolink world theme colors)]
        _AL_Theme_Weight("Weight", Range(0.0, 1.0)) = 1.0
        _AL_TC_BassReactive("Bassreactivity", Range(0.0,1.0)) = 0.75

        [Header(Audiolink Hue slider colors)]
        _AL_Hue_Weight("Weight", Range(0.0,1.0)) = 0.0
        _AL_Hue("Hue", Range(0.0,1.0)) = 0.0
        _AL_Hue_BassReactive("Bassreactiviy", Range(0.0,1.0)) = 0.75

        [Header(Effects)]
        _MonoChrome("MonoChrome", Range(0.0,1.0)) = 0.0
        _Voronoi("Voronoi", Range(0.0,1.0)) = 0.0
        _LightDiffuseness ("Shadow Diffuseness",Range(0.0,1.0)) = 0.1

        [Header(Multi Texture)]
        [Toggle(MULTI_TEXTURE)] _MultiTexture("Use multi texture", Float) = 0
        _MainTexArray ("Other textures", 2DArray) = "" {}
        _OtherTextureId ("Other texture Id", Int) = 0


    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags
        {
            "RenderType" = "Opaque" "Queue" = "Geometry" "VRCFallback" = "ToonCutout"
        }

        LOD 100
        Pass
        {
            Name "OpaqueForwardBase"
            Tags
            {
                "RenderType" = "AlphaTest"
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
            #pragma vertex bigi_toon_vert
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
                "RenderType" = "Transparent"
                "Queue" = "Transparent"
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
            #pragma vertex bigi_toon_vert
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
            #pragma vertex bigi_toon_vert
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
                o.color = b_effects::apply_effects(i.uv, mask, orig_color, lighting, i.staticTexturePos);
                UNITY_APPLY_FOG(i.fogCoord, o.color);
                o.color = o.color * _AddLightIntensity;
                return o;
            }
            ENDCG
        }


        Pass
        {
            Name "Outline"
            Tags
            {
                "Queue" = "Overlay"
                "RenderType" = "TransparentCutout"
            }
            Cull Off
            ZWrite On
            ZTest LEqual
            AlphaToMask On
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
            #pragma multi_compile_local __ MULTI_TEXTURE

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
                o.pos = lerp(0.0, o.pos, smoothstep(0.0,Epsilon, _OutlineWidth));
                return o;
            }

            fragOutput frag(v2f i)
            {
                clip(_OutlineWidth - Epsilon);
                fragOutput o;
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                GET_SOUND_COLOR(scol);
                o.color = half4(scol.rgb * scol.a, smoothstep(0.0, 0.05, scol.a));
                clip(o.color.a - Epsilon);
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
            #include "UnityStandardShadow.cginc"

            struct v2f {
                V2F_SHADOW_CASTER;
                UNITY_VERTEX_INPUT_INSTANCE_ID UNITY_VERTEX_OUTPUT_STEREO
                #if defined(UNITY_STANDARD_USE_SHADOW_UVS)
                    float2 tex : TEXCOORD1;

                    #if defined(_PARALLAXMAP)
                        half3 viewDirForParallax : TEXCOORD2;
                    #endif
                #endif
                //float4 uv : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                
                #if defined(UNITY_STANDARD_USE_SHADOW_UVS)
                    o.tex = TRANSFORM_TEX(v.uv0, _MainTex);

                    #ifdef _PARALLAXMAP
                        TANGENT_SPACE_ROTATION;
                        o.viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
                    #endif
                #endif
                
                //o.uv = v.texcoord;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i)
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)

                #if defined(UNITY_STANDARD_USE_SHADOW_UVS)
                    #if defined(_PARALLAXMAP) && (SHADER_TARGET >= 30)
                        half3 viewDirForParallax = normalize(i.viewDirForParallax);
                        fixed h = tex2D (_ParallaxMap, i.tex.xy).g;
                        half2 offset = ParallaxOffset1Step (h, _Parallax, viewDirForParallax);
                        i.tex.xy += offset;
                    #endif

                    #if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
                        half alpha = _Color.a;
                    #else
                        half alpha = tex2D(_MainTex, i.tex.xy).a * _Color.a;
                    #endif
                    #if defined(_ALPHATEST_ON)
                        clip (alpha - _Cutoff);
                    #endif
                    #if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
                        #if defined(_ALPHAPREMULTIPLY_ON)
                            half outModifiedAlpha;
                            PreMultiplyAlpha(half3(0, 0, 0), alpha, SHADOW_ONEMINUSREFLECTIVITY(i.tex), outModifiedAlpha);
                            alpha = outModifiedAlpha;
                        #endif
                        #if defined(UNITY_STANDARD_USE_DITHER_MASK)
                            // Use dither mask for alpha blended shadows, based on pixel position xy
                            // and alpha level. Our dither texture is 4x4x16.
                            #ifdef LOD_FADE_CROSSFADE
                                #define _LOD_FADE_ON_ALPHA
                                alpha *= unity_LODFade.y;
                            #endif
                            half alphaRef = tex3D(_DitherMaskLOD, float3(vpos.xy*0.25,alpha*0.9375)).a;
                            clip (alphaRef - 0.01);
                        #else
                            clip (alpha - _Cutoff);
                        #endif
                    #endif
                #endif // #if defined(UNITY_STANDARD_USE_SHADOW_UVS)

                #ifdef LOD_FADE_CROSSFADE
                    #ifdef _LOD_FADE_ON_ALPHA
                        #undef _LOD_FADE_ON_ALPHA
                    #else
                        UnityApplyDitherCrossFade(vpos.xy);
                    #endif
                #endif


                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}