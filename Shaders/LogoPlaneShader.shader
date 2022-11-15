Shader "Bigi/LogoPlane"
{
    Properties
    {
        [MainTexture] _MainTex ("Texture", 2D) = "black" {}
        _VDivs ("Vertical Cells", Int) = 2
        _HDivs ("Horizontal Cells", Int) = 2
        _CellNumber ("CellNumber", Int) = 0
        _AudioIntensity ("AudioLink Intensity (0.5 in normal)", Range(0.0,1.0)) = 0.5
        _ColorChordIndex ("ColorChord Index (0=Old behaviour, 1-4 color chords) (0-4)", Int) = 1
        [MaterialToggle] _UseBassIntensity ("Use Lower Tone Intensity", Range(0.0,1.0) ) = 0.0
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"}
        
        LOD 100

        Pass {
            Name "TransparentForwardBase"
            Tags {"LightMode" = "ForwardBase" "VRCFallback"="ToonCutout"}
            Cull Off
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma instancing_options assumeuniformscaling
            #pragma multi_compile_instancing
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fwdbasealpha
            #pragma multi_compile_lightpass
            #pragma multi_compile_fog
            #pragma target 3.0
            #pragma vertex vert alpha
            #pragma fragment frag alpha
            
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            UNITY_DECLARE_TEX2D(_MainTex);
            float4 _MainTex_ST;

            uniform uint _VDivs;
            uniform uint _HDivs;
            uniform uint _CellNumber;

            #include "./Includes/PassDefault.cginc"
            #include "./Includes/BigiLightUtils.cginc"
            #include "./Includes/BigiSoundUtils.cginc"

            //intermediate
            struct v2f
            {
                UNITY_POSITION(pos);//float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                half2 uv : TEXCOORD0; //texture coordinates
                LIGHTING_COORDS(1,2)
                UNITY_FOG_COORDS(3) //put for info into TEXCOORD2
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };


            #ifndef BIGI_DEFAULT_FRAGOUT
            #define BIGI_DEFAULT_FRAGOUT
            struct fragOutput {
                fixed4 color : SV_Target;
            };
            #endif

            v2f vert (appdata_base v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.pos = UnityObjectToClipPos(v.vertex);
                
                const float2 cell_size = float2(1.0/_HDivs,1.0/_VDivs);
                const uint2 coords = uint2(_CellNumber % _HDivs,floor(_CellNumber / _HDivs));
                const half2 start_coord = cell_size * coords;
                const half2 pos = TRANSFORM_TEX(v.texcoord,_MainTex) * cell_size;
                o.uv = start_coord + pos;
                o.normal = v.normal;
                UNITY_TRANSFER_LIGHTING(o,o.pos)
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            uniform half _AudioIntensity;
            uniform int _ColorChordIndex;
            uniform half _UseBassIntensity;
            fragOutput frag (v2f i)
            {
                UNITY_TRANSFER_INSTANCE_ID(i, o);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
                fragOutput o;
                UNITY_INITIALIZE_OUTPUT(fragOutput,o);
                fixed4 orig_color = UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
                if(orig_color.a <= Epsilon){
                    clip(-1.0);
                    discard;
                }
                half4 sound = b_sound::GetSoundColor(_ColorChordIndex,_UseBassIntensity,_AudioIntensity);
                half soundIntensity = clamp(RGBToHSV(sound).z,0.0,1.0);
                half textureIntensity = clamp(RGBToHSV(orig_color).z,0.0,1.0);
                fixed4 normalColor = orig_color * b_light::GetLighting(i.normal, _WorldSpaceLightPos0, _LightColor0, LIGHT_ATTENUATION(i));
                o.color = lerp(normalColor,fixed4(sound.rgb,normalColor.a),b_sound::Scale(soundIntensity * textureIntensity,1.0));
                //o.color = orig_color;
                UNITY_APPLY_FOG(i.fogCoord, o.color);
                return o;
            }

            ENDCG
        }

    }
}
