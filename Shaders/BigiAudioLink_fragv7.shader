Shader "Bigi/AudioLink_fragv7"
{
    Properties
    {
        [MainTexture] _MainTex ("Texture", 2D) = "black" {}
        _Spacey ("Spacey Texture", 2D) = "black" {}
        _SpaceyScaling ("Spraycey Texture scaling (high values shrink the texture)", Float) = 5.0
        _Mask ("Mask", 2D) = "black" {}
        _ALThreshold ("AudioLink Threshold", Range(0.0,1.0)) = 0.001
        _ColorChordIndex ("ColorChord Index (0=Old behaviour, 5=Weird mix) (0-5)", Int) = 0
        _DMXGroup ("DMX Group", Int) = 2
        _ExtraLightIntensity ("Other lighting intensity", Range(0.0,1.0)) = 1.0
        _OutlineWidth ("Outline Width", Range(0.0,1.0)) = 0.5


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
            #include "./Includes/SimpleVert.cginc"
            #include "./Includes/AudioLink.cginc"
            #include "./Includes/VRSL-DMXAvatarFunctions.cginc"

            half B_AlLerp(half2 xy1, half2 xy2) {
                return lerp( AudioLinkLerp(xy1).r, AudioLinkLerp(xy2).r, 0.5);
            }

            half4 B_AudioLink_Allchanels(){
                half4 sound;
                half2 al_cords = ALPASS_AUDIOLINK;
                half2 filteredCords = ALPASS_FILTEREDAUDIOLINK + uint2(15,0);
                sound.r = B_AlLerp(al_cords,filteredCords); //bass
                sound.g = B_AlLerp(al_cords+int2(0,1),filteredCords+int2(0,1)); //low-mid
                sound.b = B_AlLerp(al_cords+int2(0,2),filteredCords+int2(0,2)); //high-mid
                sound.a = B_AlLerp(al_cords+int2(0,3),filteredCords+int2(0,3)); //treble
                return sound;
            }

            fixed4 B_Scale(fixed4 x){
                return -pow((x-1.0),6.0)+1.0;
            }

            fragOutput frag (v2f i)
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                fragOutput o;
                fixed4 orig_color= UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
                if(orig_color.a < 1.0){
                    discard;
                    clip(-1.0);
                }
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed3 lighting = i.diff * shadow + i.ambient;
                o.color = orig_color * half4(lighting,1.0);
                fixed weight = 0.0;
                int count = 0;
                fixed4 mask = UNITY_SAMPLE_TEX2D_SAMPLER(_Mask,_MainTex, i.uv);
                fixed3 alc = 0.0;
                if(mask.b > Epsilon){
                    if(_ALThreshold > Epsilon){
                        if(AudioLinkIsAvailable()){
                            fixed4 sound =  B_Scale(B_AudioLink_Allchanels());
                            fixed3 endColor = fixed3(0.0,0.0,0.0);
                            if(_ColorChordIndex <= Epsilon){
                                endColor.r = sound.a;
                                endColor.g = (sound.g/2.0) + (sound.b/2.0);
                                endColor.b = sound.r;
                            }else{
                                if(_ColorChordIndex >= 5){
                                    half iWeight = 1.0;
                                    float4 c1 = AudioLinkData(ALPASS_THEME_COLOR0);
                                    float4 c2 = AudioLinkData(ALPASS_THEME_COLOR1);
                                    float4 c3 = AudioLinkData(ALPASS_THEME_COLOR2);
                                    float4 c4 = AudioLinkData(ALPASS_THEME_COLOR3);
                                    iWeight += sound.r * c1.a;
                                    endColor = lerp(endColor,c1,sound.r/iWeight);
                                    iWeight += sound.g * c2.a;
                                    endColor = lerp(endColor,c2,sound.g/iWeight);
                                    iWeight += sound.b * c3.a;
                                    endColor = lerp(endColor,c3,sound.b/iWeight);
                                    iWeight += sound.a * c4.a;
                                    endColor = lerp(endColor,c4,sound.a/iWeight);
                                }else{
                                    float4 col = AudioLinkData(ALPASS_THEME_COLOR0+(half2(_ColorChordIndex - 1.0,0.0)));
                                    half3 hsv = RGBToHSV(col.rgb);
                                    hsv.z = (float(sound.r/4.0) + float(sound.g/4.0) + float(sound.b/4.0) + float(sound.a/4.0)) * col.a;
                                    endColor = HSVToRGB(hsv);
                                }
                            }

                            half soundIntensity = RGBToHSV(endColor.rgb).z;

                            if(soundIntensity > Epsilon){
                                half selfWeight = soundIntensity * mask.b * _ALThreshold;
                                weight += selfWeight;
                                count++;
                                alc = lerp(alc, endColor.rgb , selfWeight/weight);
                            }
                        }
                    }else{
                        if(_DMXGroup > Epsilon){
                            //half4 dmxMask = tex2D (_DMXEmissionMask, IN.uv_DMXEmissionMask);
                            half dmxIntensity = GetDMXIntensity(_DMXGroup);
                            half3 dmxColor = GetDMXColor(_DMXGroup).rgb * dmxIntensity;
                            
                            half3 dmxHSV = RGBtoHCV(dmxColor.rgb);

                            if(dmxIntensity - 0.5 > Epsilon){
                                half selfWeight = (clamp(dmxIntensity-0.5,0.0,0.5) * mask.b)*2.0;
                                weight += selfWeight;
                                count++;
                                alc = lerp(alc, dmxColor * dmxHSV.z, selfWeight/weight);
                            }
                        }
                    }
                }

                if(mask.g > Epsilon){
                    fixed4 bg = UNITY_SAMPLE_TEX2D(_Spacey,i.screenPos * _SpaceyScaling);
                    half selfWeight = mask.g;
                    weight += selfWeight;
                    count++;
                    alc = lerp(alc, bg.rgb, selfWeight/weight);
                }

                if(mask.r > Epsilon){
                    if(weight < .1){
                        half selfWeight = mask.r;
                        weight += selfWeight;
                        count++;
                        alc = lerp(alc,orig_color,selfWeight/weight);
                    }
                }

                if(weight > Epsilon){
                    o.color = lerp(o.color,fixed4(alc,o.color.a),weight/count);
                    //o.color = fixed4(alc,1.0);
                }
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
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert alpha
            #pragma fragment frag alpha
            //#include "./Includes/PassDefault.cginc"
            #include "./Includes/SimpleVert.cginc"
        

            fragOutput frag (v2f i)
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                fragOutput o;
                fixed4 orig_color= UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
                if(!(orig_color.a < 1.0)){
                    discard;
                    clip(-1.0);
                }
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed3 lighting = i.diff * shadow + i.ambient;
                o.color = orig_color * half4(lighting,1.0);
                return o;
            }

            ENDCG
        }

        Pass {
            Name "ForwardAdd"
            Tags { "LightMode" = "ForwardAdd" "RenderType"="Transparent" "Queue" = "Transparent" }
            Cull Off
            ZWrite Off
            ZTest LEqual
            Blend One One
            CGPROGRAM
            #pragma vertex vert alpha
            #pragma fragment frag alpha
            //#include "./Includes/PassDefault.cginc"
            #include "./Includes/SimpleVert.cginc"
            float Epsilon = 1e-10;
            uniform half _ExtraLightIntensity;

            fragOutput frag (v2f i)
            {
                fragOutput o;
                
                
                if(_ExtraLightIntensity > Epsilon) {
                    UNITY_SETUP_INSTANCE_ID(i);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                    fixed4 orig_color = UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
                    fixed shadow = SHADOW_ATTENUATION(i);
                    fixed3 lighting = i.diff * shadow  * orig_color.rgb * _ExtraLightIntensity * orig_color.a;
                    o.color = half4(lighting, orig_color.a);
                }else{
                    discard;
                    clip(-1.0);
                    o.color = 0.0;
                }
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

            #include "UnityCG.cginc"
            #include "./Includes/AudioLink.cginc"

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

            struct fragOutput {
                fixed4 color : SV_Target;
            };
            uniform int _ColorChordIndex;
            uniform float _OutlineWidth;

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
                if(AudioLinkIsAvailable()){
                    UNITY_SETUP_INSTANCE_ID(i);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                    int ccI = (_ColorChordIndex - 1) & 3;
                    o.color=AudioLinkData(ALPASS_THEME_COLOR0 + uint2(ccI,0.0));
                }else{
                    discard;
                    clip(-1.0);
                    o.color=float4(0.0,0.0,0.0,0.0);
                }
                return o;
            }

            ENDCG

        }

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
