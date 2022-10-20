Shader "Custom/BigiAudioLinkv2"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_Threshold ("Sound threshold", Range(0.0,0.5)) = 0.05
		_ReplaceMask ("Replace Mask", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "VRCFallback"="Toon" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface bsurf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
		
		#include "UnityCG.cginc"
		#include "../../../AudioLink/Shaders/AudioLink.cginc"
		
        sampler2D _MainTex;
		sampler2D _ReplaceMask;
		float _Threshold;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
		
		float isIntenseEnough(float3 sound){
				if(sound.r > _Threshold || sound.g > _Threshold || sound.b > _Threshold){
					return 1.0;
				}else{
					return 0.0;
				}
		}
		
		
		float4 B_AlLerp(float2 xy) {
			return lerp( AudioLinkData(xy), AudioLinkData(xy+float2(1.0,0.0)),0.5 );
		}
		
		float4 B_AudioLink_Allchanels(float2 al_cords){
			float4 sound;
			sound.b = B_AlLerp(al_cords).r; //bass
			sound.g = B_AlLerp(al_cords+int2(0,1)).r; //low-mid
			sound.a = B_AlLerp(al_cords+int2(0,2)).r; //high-mid
			sound.r = B_AlLerp(al_cords+int2(0,3)).r; //treble
			return sound;
		}

        void bsurf (Input IN, inout SurfaceOutputStandard o)
        {
			// Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
           
			if(AudioLinkIsAvailable()){
				fixed4 mask = tex2D(_ReplaceMask, IN.uv_MainTex);
				fixed3 alc = fixed3(0.0,0.0,0.0);
				fixed count = 0.0;
				
				if(mask.r > 0.0){
					fixed2 al_cords = ALPASS_AUDIOLINK;
					fixed4 sound = B_AudioLink_Allchanels(ALPASS_AUDIOLINK);
					count = count+mask.r;
					alc = sound.rgb * mask.rrr;
					
				}else if(mask.g > 0.0){
					fixed4 sound = AudioLinkLerp( ALPASS_CCSTRIP + float2(10.0,0)).rgba;
					count = count + mask.g;
					alc = sound.rgb * mask.ggg;
				}
				if(count > 0.0 && isIntenseEnough(alc)){
					o.Albedo = alc;
					o.Alpha = min(1.0,count);
					o.Emission = o.Albedo;
					return;
				}
				
			}
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
           
        }

        /*
        struct SurfaceOutput
		{
		    fixed3 Albedo;  // diffuse color
		    fixed3 Normal;  // tangent space normal, if written
		    fixed3 Emission;
		    half Specular;  // specular power in 0..1 range
		    fixed Gloss;    // specular intensity
		    fixed Alpha;    // alpha for transparencies
		};
		struct SurfaceOutputStandard
		{
			fixed3 Albedo;      // base (diffuse or specular) color
			fixed3 Normal;      // tangent space normal, if written
			half3 Emission;
			half Metallic;      // 0=non-metal, 1=metal
			half Smoothness;    // 0=rough, 1=smooth
			half Occlusion;     // occlusion (default 1)
			fixed Alpha;        // alpha for transparencies
		};
		struct SurfaceOutputStandardSpecular
		{
			fixed3 Albedo;      // diffuse color
			fixed3 Specular;    // specular color
			fixed3 Normal;      // tangent space normal, if written
			half3 Emission;
			half Smoothness;    // 0=rough, 1=smooth
			half Occlusion;     // occlusion (default 1)
			fixed Alpha;        // alpha for transparencies
		};
		*/
        ENDCG
    }
    FallBack "Diffuse"
}
