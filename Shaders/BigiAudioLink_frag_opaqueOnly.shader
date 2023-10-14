Shader "Bigi/AudioLink_frag_opaqueOnly"
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
        _LightDiffuseness ("Shadow Diffuseness",Range(0.0,1.0)) = 0.1

        [Header(Multi Texture)]
        [Toggle(MULTI_TEXTURE)] _MultiTexture("Use multi texture", Float) = 0
        _MainTexArray ("Other textures", 2DArray) = "" {}
        _OtherTextureId ("Other texture Id", Int) = 0


    }
    SubShader
    {
       UsePass "Bigi/AudioLink_frag/OPAQUEFORWARDBASE"
       UsePass "Bigi/AudioLink_frag/FORWARDADD"
       UsePass "Bigi/AudioLink_frag/OUTLINE"
       UsePass "Bigi/AudioLink_frag/SHADOWPASS"
    }
}