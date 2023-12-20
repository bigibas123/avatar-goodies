Shader "Bigi/AudioLink_frag"
{
    Properties
    {
        [MainTexture] _MainTex ("Texture", 2D) = "black" {}
        [Toggle(DO_ALPHA_PLS)] _UsesAlpha("Is transparent", Float) = 1
        _Spacey ("Spacey Texture", 2D) = "black" {}
        _EmissionStrength ("Emission strength", Range(0.0,2.0)) = 1.0
        [NoScaleOffset] _Mask ("Mask", 2D) = "black" {}
        [NoScaleOffset] _OcclusionMap ("Ambient occlusion map", 2D) = "white" {}
        [Toggle(NORMAL_MAPPING)] _UsesNormalMap("Enable normal map", Float) = 1
        [NoScaleOffset] _BumpMap("Normal Map", 2D) = "bump" {}

        [Header(Lighting)]
        _LightDiffuseness ("Shadow Diffuseness",Range(0.0,1.0)) = 0.1
        _AddLightIntensity ("Additive lighting intensity", Range(0.0,2.0)) = 1.0
        _VertLightIntensity ("Vertex lighting intensity", Range(0.0,2.0)) = 1.0
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
        _OutlineWidth ("Outline Width", Range(0.0,1.0)) = 0.0

        [Header(Multi Texture)]
        [Toggle(MULTI_TEXTURE)] _MultiTexture("Use multi texture", Float) = 0
        _MainTexArray ("Other textures", 2DArray) = "" {}
        _OtherTextureId ("Other texture Id", Int) = 0


    }
    
    CustomEditor "Characters.Common.Editor.Tools.BigiShaderEditor.BigiShaderEditor"
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
                "Queue" = "AlphaTest"
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
            #pragma vertex bigi_toon_vert
            #pragma fragment frag

            #include_with_pragmas "./Includes/Pragmas/ForwardBase.cginc"
            
            #include "./Includes/ToonVert.cginc"
            #include "./Includes/LightUtilsDefines.cginc"
            #ifdef NORMAL_MAPPING
            #include "./Includes/NormalUtils.cginc"
            #endif

            #include "./Includes/BigiEffects.cginc"

            fragOutput frag(v2f i)
            {
                const fixed4 orig_color = GET_TEX_COLOR(i.uv);
                #ifdef DO_ALPHA_PLS
                clip(orig_color.a - (1.0-Epsilon));
                #endif
                fragOutput o;
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                #ifdef NORMAL_MAPPING
                i.normal = b_normalutils::recalculate_normals(i.normal, GET_NORMAL(i.uv), i.tangent, i.bitangent);
                #endif

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
            #pragma vertex vert
            #pragma fragment frag

            #include_with_pragmas "./Includes/Pragmas/ForwardBase.cginc"

            #include "./Includes/ToonVert.cginc"
            #include "./Includes/LightUtilsDefines.cginc"
            #ifdef NORMAL_MAPPING
            #include "./Includes/NormalUtils.cginc"
            #endif
            #include "./Includes/BigiEffects.cginc"

            v2f vert(appdata v)
            {
                #ifdef DO_ALPHA_PLS
                return bigi_toon_vert(v);
                #else
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                return o;
                #endif 
            }

            fragOutput frag(v2f i)
            {
                #ifdef DO_ALPHA_PLS
                const fixed4 orig_color = GET_TEX_COLOR(i.uv);
                clip((orig_color.a - (1.0-Epsilon)) * -1.0);
                fragOutput o;
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                #ifdef NORMAL_MAPPING
                i.normal = b_normalutils::recalculate_normals(i.normal, GET_NORMAL(i.uv), i.tangent, i.bitangent);
                #endif

                BIGI_GETLIGHT_DEFAULT(lighting);

                const fixed4 mask = GET_MASK_COLOR(i.uv);
                o.color = b_effects::apply_effects(i.uv, mask, orig_color, lighting, i.staticTexturePos);
                UNITY_APPLY_FOG(i.fogCoord, o.color);
                return o;
                #else
                fragOutput o;
                UNITY_INITIALIZE_OUTPUT(fragOutput,o);
                return o;
                #endif
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
            Blend SrcAlpha One
            Stencil
            {
                Ref 4
                Comp Always
                WriteMask 4
                Pass Replace
            }
            CGPROGRAM
            #pragma vertex bigi_toon_vert
            #pragma fragment frag

            #include_with_pragmas "./Includes/Pragmas/ForwardAdd.cginc"


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
                #ifdef NORMAL_MAPPING
                i.normal = b_normalutils::recalculate_normals(i.normal, GET_NORMAL(i.uv), i.tangent, i.bitangent);
                #endif
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
            #pragma vertex vert
            #pragma fragment frag

            #include_with_pragmas "./Includes/Pragmas/Global.cginc"


            #include "./Includes/BigiShaderParams.cginc"
            #include "./Includes/SoundUtilsDefines.cginc"


            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID };

            //intermediate
            struct v2f {
                UNITY_POSITION(pos); //float4 pos : SV_POSITION;
                half4 soundColor: COLOR0;
                UNITY_VERTEX_INPUT_INSTANCE_ID UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                
                GET_SOUND_COLOR(scol);
                o.soundColor = scol;
                
                float3 offset = v.normal.xyz * (_OutlineWidth * 0.01) * smoothstep(0.0, 0.5, scol.a);
                
                o.pos = UnityObjectToClipPos(v.vertex + offset);
                o.pos = lerp(0.0, o.pos, smoothstep(0.0,Epsilon, _OutlineWidth));
                
                return o;
            }

            fragOutput frag(v2f i)
            {
                clip(_OutlineWidth - Epsilon);
                clip(i.soundColor.a - Epsilon);
                fragOutput o;
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                o.color = half4(i.soundColor.rgb * i.soundColor.a, smoothstep(0.0, 0.05, i.soundColor.a));
                clip(o.color.a - Epsilon);
                return o;
            }
            ENDCG

        }
        Pass
        {
            Name "META"
            Tags
            {
                "LightMode" = "Meta"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include_with_pragmas "./Includes/Pragmas/Global.cginc"

            #include "UnityCG.cginc"
            #include "UnityMetaPass.cginc"
            #include "./Includes/BigiEffects.cginc"
            #include "./Includes/BigiShaderTextures.cginc"
            #include "./Includes/BigiShaderParams.cginc"
            
            struct v2f {
                UNITY_POSITION(pos);
                float2 uv : TEXCOORD0;
                float2 uvIllum : TEXCOORD1;
                #ifdef EDITOR_VISUALIZATION
                float2 vizUV : TEXCOORD2;
                float4 lightCoord : TEXCOORD3;
                #endif
                float4 staticTexturePos : TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _Illum_ST;

            v2f vert(appdata_full v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
                o.uv = DO_TRANSFORM(v.texcoord);
                o.uvIllum = TRANSFORM_TEX(v.texcoord, _Illum);
                #ifdef EDITOR_VISUALIZATION
                    o.vizUV = 0;
                    o.lightCoord = 0;
                    if (unity_VisualizationMode == EDITORVIZ_TEXTURE)
                        o.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, v.texcoord.xy, v.texcoord1.xy, v.texcoord2.xy, unity_EditorViz_Texture_ST);
                    else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK)
                    {
                        o.vizUV = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                        o.lightCoord = mul(unity_EditorViz_WorldToLight, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)));
                    }
                #endif
                o.staticTexturePos = ComputeScreenPos(o.pos);
                return o;
            }
            
            sampler2D _Illum;
            
            half4 frag(v2f i) : SV_Target
            {
                UnityMetaInput metaIN;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);

                fixed4 orig_color = GET_TEX_COLOR(i.uv);
                fixed4 mask_color = GET_MASK_COLOR(i.uv);
                
                
                metaIN.Albedo = b_effects::apply_effects(i.uv,mask_color,orig_color,half4(1.0,1.0,1.0,1.0),i.staticTexturePos).rgb;
                metaIN.Emission = b_effects::get_meta_emissions(orig_color,mask_color,_EmissionStrength) * 5.0;
                
                #if defined(EDITOR_VISUALIZATION)
                    metaIN.VizUV = i.vizUV;
                    metaIN.LightCoord = i.lightCoord;
                #endif

                return UnityMetaFragment(metaIN);
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
            #pragma vertex vert alpha
            #pragma fragment frag alpha

            #include_with_pragmas "./Includes/Pragmas/Meta.cginc"

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