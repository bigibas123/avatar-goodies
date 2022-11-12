Shader "Bigi/LogoPlane"
{
    Properties
    {
        [MainTexture] _MainTex ("Texture", 2D) = "black" {}
        _VDivs ("Vertical Cells", Int) = 2
        _HDivs ("Horizontal Cells", Int) = 2
        _CellNumber ("CellNumber", Int) = 0
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"}
        
        LOD 100

        Pass {
            Name "TransparentForwardBase"
            Tags {"LightMode" = "ForwardBase" "VRCFallback"="ToonCutout"}
            Cull Back
            ZWrite On
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
                float cellWidth = 1.0/_HDivs;
                float cellHeigth = 1.0/_VDivs;
                uint xCoord = _CellNumber % _HDivs;
                uint yCoord = floor(_CellNumber / _HDivs);
                half2 startCoord = half2(cellWidth * xCoord,cellHeigth * yCoord);
                half2 pos = TRANSFORM_TEX(v.texcoord,_MainTex) / half2(_HDivs,_VDivs);
                o.uv = startCoord + pos;
                //o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                o.normal = v.normal;
                UNITY_TRANSFER_LIGHTING(o,o.pos)
                //TRANSFER_SHADOW(o)
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

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
                o.color = orig_color * b_light::GetLighting(i.normal, _WorldSpaceLightPos0, _LightColor0, LIGHT_ATTENUATION(i));
                //o.color = orig_color;
                //UNITY_APPLY_FOG(i.fogCoord, o.color);
                return o;
            }

            ENDCG
        }

    }
}
