Shader "Bigi/AudioLink_fragv7"
{
    Properties
    {
        [MainTexture] _MainTex ("Texture", 2D) = "black" {}
        _Spacey ("Spacey Texture", 2D) = "black" {}
        _EmissionStrength ("Emission strength", Range(0.0,1.0)) = 1.0
        [NoScaleOffset] _Mask ("Mask", 2D) = "black" {}
        [NoScaleOffset] _AOMap ("Ambient occlusion map", 2D) = "white" {}
        _AudioIntensity ("AudioLink Intensity (0.5 in normal)", Range(0.0,1.0)) = 0.001
        _ColorChordIndex ("ColorChord Index (0=Old behaviour, 1-4 color chords) (0-4)", Int) = 0
        _DMXGroup ("DMX Group", Int) = 2
        _OutlineWidth ("Outline Width", Range(0.0,1.0)) = 0.5
        [MaterialToggle] _UseBassIntensity ("Use Lower Tone Intensity", Range(0.0,1.0) ) = 0.0
        _AddLightIntensity ("Additive lighting intensity", Range(0.0,1.0)) = 0.1

    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        
        LOD 100

        Pass
        {
            Name "OpaqueForwardBase"
            Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "VRCFallback"="ToonCutout" "LightMode" = "ForwardBase"}
            Cull Back
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
            #pragma vertex vert
            #pragma fragment frag
           
            #include "./Includes/PassDefault.cginc"
            #include "./Includes/BigiShaderParams.cginc"
            #include "./Includes/ToonVert.cginc"
            #include "./Includes/BigiSoundUtils.cginc"
            #include "./Includes/BigiLightUtils.cginc"

            fragOutput frag (v2f i)
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                fragOutput o;
                UNITY_INITIALIZE_OUTPUT(fragOutput, o);
                fixed4 orig_color= UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
                if(orig_color.a < 1.0){
                    discard;
                    clip(-1.0);
                }
                fixed4 lighting = b_light::GetLighting(i.normal, _WorldSpaceLightPos0, _LightColor0, LIGHT_ATTENUATION(i), UNITY_SAMPLE_TEX2D_SAMPLER(_AOMap,_MainTex, i.uv).r);
                o.color = orig_color * lighting;
                fixed weight = 0.0;
                int count = 0;
                fixed4 mask = UNITY_SAMPLE_TEX2D_SAMPLER(_Mask,_MainTex, i.uv);
                fixed3 alc = 0.0;
                if(mask.b > Epsilon){
                    if(_AudioIntensity > Epsilon){
                        if(AudioLinkIsAvailable()){
                            fixed3 soundColor = b_sound::GetSoundColor(_ColorChordIndex,_UseBassIntensity,_AudioIntensity);
                            half soundIntensity = RGBToHSV(soundColor.rgb).z;
                            half selfWeight = soundIntensity * mask.b;
                            weight += selfWeight;
                            count++;
                            alc = lerp(alc, soundColor.rgb , selfWeight/weight);
                        }
                    }else{
                        b_sound::dmx_info dmxI = b_sound::GetDMXInfo(_DMXGroup);
                        half selfWeight = dmxI.Intensity * mask.b;
                        weight += selfWeight;
                        count++;
                        alc = lerp(alc, dmxI.ResultColor, selfWeight/weight);
                    }
                }

                if(mask.g > Epsilon){
                    float2 tpos = TRANSFORM_TEX((i.screenPos.xy / i.screenPos.w),_Spacey);
                    fixed4 bg = UNITY_SAMPLE_TEX2D(_Spacey,tpos);
                    half selfWeight = mask.g * clamp(lighting,0.2,1.0);
                    weight += selfWeight;
                    count++;
                    alc = lerp(alc, bg.rgb, selfWeight/weight);
                }

                if(mask.r > Epsilon){
                    if(weight < .1){
                        half selfWeight = mask.r * _EmissionStrength;
                        weight += selfWeight;
                        count++;
                        alc = lerp(alc,orig_color,selfWeight/weight);
                    }
                }

                if(weight > Epsilon){
                    o.color = lerp(o.color,fixed4(alc,o.color.a),weight/count);
                    //o.color = fixed4(alc,1.0);
                }
                UNITY_APPLY_FOG(i.fogCoord, o.color);
                return o;
            }

            ENDCG
        }

        Pass {
            Name "TransparentForwardBase"
            Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "LightMode" = "ForwardBase" "VRCFallback"="ToonCutout"}
            Cull Off
            ZWrite Off
            ZTest LEqual
            //Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert alpha
            #pragma fragment frag alpha
            #include "./Includes/ToonVert.cginc"
            #include "./Includes/BigiLightUtils.cginc"
        

            fragOutput frag (v2f i)
            {
                fragOutput o;
                UNITY_INITIALIZE_OUTPUT(fragOutput, o);
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                
                fixed4 orig_color= UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
                if(!(orig_color.a < 1.0)){
                     discard;
                     clip(-1.0);
                }
                o.color = orig_color * b_light::GetLighting(i.normal, _WorldSpaceLightPos0, _LightColor0, SHADOW_ATTENUATION(i));
                return o;
            }

            ENDCG
        }

        
        Pass {
            Tags { "LightMode" = "ForwardAdd" "Queue" = "Transparent" }
            Cull Off
            ZWrite Off
            ZTest LEqual
            Blend One One
            Stencil
            {
                Ref 1
                ReadMask 1
                Comp Equal
            }
            CGPROGRAM
            #pragma vertex vert alpha
            #pragma fragment frag alpha
            #pragma instancing_options assumeuniformscaling
            #pragma multi_compile_instancing
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fwdbasealpha
            #pragma multi_compile_lightpass
            #pragma multi_compile_shadowcollector
            #pragma target 3.0

            #include "./Includes/ToonVert.cginc"
            #include "./Includes/BigiLightUtils.cginc"
            
            fragOutput frag (v2f i)
            {
                fragOutput o;
                UNITY_INITIALIZE_OUTPUT(fragOutput, o);
                
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                fixed4 orig_color= UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
                if(orig_color.a < 1.0){
                    discard;
                    clip(-1.0);
                }
                fixed3 lighting = lerp(
                    orig_color.rgb,
                    b_light::GetLighting(i.normal, _WorldSpaceLightPos0, _LightColor0, LIGHT_ATTENUATION(i),UNITY_SAMPLE_TEX2D_SAMPLER(_AOMap,_MainTex, i.uv).r)
                    ,LIGHT_ATTENUATION(i)
                );
                o.color = half4(lighting * _AddLightIntensity, 1.0);
                //o.color = float4(1.0,1.0,1.0,1.0);
                return o;
            }

            ENDCG
        }

        
        Pass
        {
            Name "Outline"
            Tags { "RenderType" = "TransparentCutout" "Queue" = "Transparent+-1"}
            Cull Off
            ZWrite On
            ZTest LEqual
            Stencil
            {
                Ref 0
                ReadMask 7
                Comp GEqual
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "./Includes/PassDefault.cginc"
            #include "./Includes/BigiShaderParams.cginc"
            #include "./Includes/BigiSoundUtils.cginc"
            

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            //intermediate
            struct v2f
            {
                UNITY_POSITION(pos);//float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o)
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                float3 offset = v.normal.xyz * (_OutlineWidth * 0.01);
                o.pos = UnityObjectToClipPos(v.vertex + offset);
                return o;
            }

            fragOutput frag(v2f i)
            {
                fragOutput o;
                UNITY_INITIALIZE_OUTPUT(fragOutput, o);;
                if(_AudioIntensity > Epsilon){
                    if(AudioLinkIsAvailable()){
                        UNITY_SETUP_INSTANCE_ID(i);
                        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                        o.color = b_sound::GetSoundColor(_ColorChordIndex,_UseBassIntensity,_AudioIntensity);
                    }else{
                        discard;
                        clip(-1.0);
                    }
                }else{
                    if(_DMXGroup > Epsilon){
                        o.color = half4(b_sound::GetDMXInfo(_DMXGroup).ResultColor,1.0);
                    }else{
                        discard;
                        clip(-1.0);
                    }
                }
                return o;
            }

            ENDCG

        }

        //UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        Pass{
            Name "ShadowPass"
            Tags {"LightMode"="ShadowCaster"}
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
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            #pragma multi_compile_lightpass
            #include "UnityCG.cginc"

            struct v2f { 
                V2F_SHADOW_CASTER;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
                //float4 uv : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o)
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                //o.uv = v.texcoord;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i)
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG     
        }

    }
}
