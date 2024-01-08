using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

namespace Characters.Common.Editor.Tools.BigiShaderEditor
{
	public class BigiShaderEditor : ShaderGUI
	{
		private static readonly int BumpMapID = Shader.PropertyToID("_BumpMap");
		private static readonly int NormalMapEnabledID = Shader.PropertyToID("_UsesNormalMap");
		private static readonly int AlphaEnabledID = Shader.PropertyToID("_UsesAlpha");
		private static readonly int MainTextureID = Shader.PropertyToID("_MainTex");
		private static readonly int MainTextureArrayID = Shader.PropertyToID("_MainTexArray");
		private static readonly int TextureArrayEnabledID = Shader.PropertyToID("_MultiTexture");

		public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
		{
			// Custom code that controls the appearance of the Inspector goes here
			EditorGUI.BeginChangeCheck();
			foreach (Material m in materialEditor.targets)
			{
				if (m.HasProperty(BumpMapID) && m.HasProperty(NormalMapEnabledID))
				{
					bool hasNormalMap = (m.GetTexture(BumpMapID) is not null);
					m.SetFloat(NormalMapEnabledID, hasNormalMap ? 1 : 0);
					if (hasNormalMap)
					{
						m.SetFloat(NormalMapEnabledID, 1);
						m.EnableKeyword("NORMAL_MAPPING");
					}
					else
					{
						m.SetFloat(NormalMapEnabledID, 0);
						m.DisableKeyword("NORMAL_MAPPING");
					}
				}

				if (m.HasProperty(AlphaEnabledID))
				{
					bool usingArray = m.HasProperty(TextureArrayEnabledID) && m.GetFloat(TextureArrayEnabledID) > 0.1;
					var t = m.GetTexture(usingArray ? MainTextureArrayID : MainTextureID);
					bool usingAlpha = isAlphaFormat(t.graphicsFormat);
					if (usingAlpha)
					{
						m.SetFloat(AlphaEnabledID, 1);
						m.EnableKeyword("DO_ALPHA_PLS");
					}
					else
					{
						m.SetFloat(AlphaEnabledID, 0);
						m.DisableKeyword("DO_ALPHA_PLS");
					}
				}
			}

			EditorGUI.EndChangeCheck();
			base.OnGUI(materialEditor, properties);
			EditorGUI.indentLevel++;
			EditorGUI.BeginChangeCheck();

			bool emissionEnabled = materialEditor.EmissionEnabledProperty();
			materialEditor.LightmapEmissionProperty(0);
			materialEditor.LightmapEmissionFlagsProperty(0, emissionEnabled, true);
			if (EditorGUI.EndChangeCheck())
			{
				foreach (Material m in materialEditor.targets)
				{
					m.globalIlluminationFlags &=
						~MaterialGlobalIlluminationFlags.EmissiveIsBlack;
					m.globalIlluminationFlags |= MaterialGlobalIlluminationFlags.RealtimeEmissive;
				}
			}

			EditorGUI.indentLevel--;
		}

		public bool isAlphaFormat(GraphicsFormat format)
		{
			switch (format)
			{
				case GraphicsFormat.R8G8B8A8_SRGB:
				case GraphicsFormat.R8G8B8A8_UNorm:
				case GraphicsFormat.R8G8B8A8_SNorm:
				case GraphicsFormat.R8G8B8A8_UInt:
				case GraphicsFormat.R8G8B8A8_SInt:
				case GraphicsFormat.R16G16B16A16_UNorm:
				case GraphicsFormat.R16G16B16A16_SNorm:
				case GraphicsFormat.R16G16B16A16_UInt:
				case GraphicsFormat.R16G16B16A16_SInt:
				case GraphicsFormat.R32G32B32A32_UInt:
				case GraphicsFormat.R32G32B32A32_SInt:
				case GraphicsFormat.R16G16B16A16_SFloat:
				case GraphicsFormat.R32G32B32A32_SFloat:
				case GraphicsFormat.B8G8R8A8_SRGB:
				case GraphicsFormat.B8G8R8A8_UNorm:
				case GraphicsFormat.B8G8R8A8_SNorm:
				case GraphicsFormat.B8G8R8A8_UInt:
				case GraphicsFormat.B8G8R8A8_SInt:
				case GraphicsFormat.R4G4B4A4_UNormPack16:
				case GraphicsFormat.B4G4R4A4_UNormPack16:
				case GraphicsFormat.R5G5B5A1_UNormPack16:
				case GraphicsFormat.B5G5R5A1_UNormPack16:
				case GraphicsFormat.A1R5G5B5_UNormPack16:
				case GraphicsFormat.A2B10G10R10_UNormPack32:
				case GraphicsFormat.A2B10G10R10_UIntPack32:
				case GraphicsFormat.A2B10G10R10_SIntPack32:
				case GraphicsFormat.A2R10G10B10_UNormPack32:
				case GraphicsFormat.A2R10G10B10_UIntPack32:
				case GraphicsFormat.A2R10G10B10_SIntPack32:
				case GraphicsFormat.A2R10G10B10_XRSRGBPack32:
				case GraphicsFormat.A2R10G10B10_XRUNormPack32:
				case GraphicsFormat.A10R10G10B10_XRSRGBPack32:
				case GraphicsFormat.A10R10G10B10_XRUNormPack32:
				//case GraphicsFormat.RGBA_DXT1_SRGB:
				//case GraphicsFormat.RGBA_DXT1_UNorm:
				case GraphicsFormat.RGBA_DXT3_SRGB:
				case GraphicsFormat.RGBA_DXT3_UNorm:
				case GraphicsFormat.RGBA_DXT5_SRGB:
				case GraphicsFormat.RGBA_DXT5_UNorm:
				case GraphicsFormat.RGBA_BC7_SRGB:
				case GraphicsFormat.RGBA_BC7_UNorm:
				case GraphicsFormat.RGBA_PVRTC_2Bpp_SRGB:
				case GraphicsFormat.RGBA_PVRTC_2Bpp_UNorm:
				case GraphicsFormat.RGBA_PVRTC_4Bpp_SRGB:
				case GraphicsFormat.RGBA_PVRTC_4Bpp_UNorm:
				case GraphicsFormat.RGB_A1_ETC2_SRGB:
				case GraphicsFormat.RGB_A1_ETC2_UNorm:
				case GraphicsFormat.RGBA_ETC2_SRGB:
				case GraphicsFormat.RGBA_ETC2_UNorm:
				case GraphicsFormat.RGBA_ASTC4X4_SRGB:
				case GraphicsFormat.RGBA_ASTC4X4_UNorm:
				case GraphicsFormat.RGBA_ASTC5X5_SRGB:
				case GraphicsFormat.RGBA_ASTC5X5_UNorm:
				case GraphicsFormat.RGBA_ASTC6X6_SRGB:
				case GraphicsFormat.RGBA_ASTC6X6_UNorm:
				case GraphicsFormat.RGBA_ASTC8X8_SRGB:
				case GraphicsFormat.RGBA_ASTC8X8_UNorm:
				case GraphicsFormat.RGBA_ASTC10X10_SRGB:
				case GraphicsFormat.RGBA_ASTC10X10_UNorm:
				case GraphicsFormat.RGBA_ASTC12X12_SRGB:
				case GraphicsFormat.RGBA_ASTC12X12_UNorm:
				case GraphicsFormat.RGBA_ASTC4X4_UFloat:
				case GraphicsFormat.RGBA_ASTC5X5_UFloat:
				case GraphicsFormat.RGBA_ASTC6X6_UFloat:
				case GraphicsFormat.RGBA_ASTC8X8_UFloat:
				case GraphicsFormat.RGBA_ASTC10X10_UFloat:
				case GraphicsFormat.RGBA_ASTC12X12_UFloat:

					return true;


				case GraphicsFormat.DepthAuto:
				case GraphicsFormat.ShadowAuto:
				case GraphicsFormat.VideoAuto:
					return false;

				case GraphicsFormat.None:
				case GraphicsFormat.R8_SRGB:
				case GraphicsFormat.R8G8_SRGB:
				case GraphicsFormat.R8G8B8_SRGB:
				case GraphicsFormat.R8_UNorm:
				case GraphicsFormat.R8G8_UNorm:
				case GraphicsFormat.R8G8B8_UNorm:
				case GraphicsFormat.R8_SNorm:
				case GraphicsFormat.R8G8_SNorm:
				case GraphicsFormat.R8G8B8_SNorm:
				case GraphicsFormat.R8_UInt:
				case GraphicsFormat.R8G8_UInt:
				case GraphicsFormat.R8G8B8_UInt:
				case GraphicsFormat.R8_SInt:
				case GraphicsFormat.R8G8_SInt:
				case GraphicsFormat.R8G8B8_SInt:
				case GraphicsFormat.R16_UNorm:
				case GraphicsFormat.R16G16_UNorm:
				case GraphicsFormat.R16G16B16_UNorm:
				case GraphicsFormat.R16_SNorm:
				case GraphicsFormat.R16G16_SNorm:
				case GraphicsFormat.R16G16B16_SNorm:
				case GraphicsFormat.R16_UInt:
				case GraphicsFormat.R16G16_UInt:
				case GraphicsFormat.R16G16B16_UInt:
				case GraphicsFormat.R16_SInt:
				case GraphicsFormat.R16G16_SInt:
				case GraphicsFormat.R16G16B16_SInt:
				case GraphicsFormat.R32_UInt:
				case GraphicsFormat.R32G32_UInt:
				case GraphicsFormat.R32G32B32_UInt:
				case GraphicsFormat.R32_SInt:
				case GraphicsFormat.R32G32_SInt:
				case GraphicsFormat.R32G32B32_SInt:
				case GraphicsFormat.R16_SFloat:
				case GraphicsFormat.R16G16_SFloat:
				case GraphicsFormat.R16G16B16_SFloat:
				case GraphicsFormat.R32_SFloat:
				case GraphicsFormat.R32G32_SFloat:
				case GraphicsFormat.R32G32B32_SFloat:
				case GraphicsFormat.B8G8R8_SRGB:
				case GraphicsFormat.B8G8R8_UNorm:
				case GraphicsFormat.B8G8R8_SNorm:
				case GraphicsFormat.B8G8R8_UInt:
				case GraphicsFormat.B8G8R8_SInt:
				case GraphicsFormat.R5G6B5_UNormPack16:
				case GraphicsFormat.B5G6R5_UNormPack16:
				case GraphicsFormat.E5B9G9R9_UFloatPack32:
				case GraphicsFormat.B10G11R11_UFloatPack32:
				case GraphicsFormat.R10G10B10_XRSRGBPack32:
				case GraphicsFormat.R10G10B10_XRUNormPack32:
				case GraphicsFormat.D16_UNorm:
				case GraphicsFormat.D24_UNorm:
				case GraphicsFormat.D24_UNorm_S8_UInt:
				case GraphicsFormat.D32_SFloat:
				case GraphicsFormat.D32_SFloat_S8_UInt:
				case GraphicsFormat.S8_UInt:
				case GraphicsFormat.RGBA_DXT1_SRGB: //case GraphicsFormat.RGB_DXT1_SRGB:
				case GraphicsFormat.RGBA_DXT1_UNorm: //case GraphicsFormat.RGB_DXT1_UNorm:
				case GraphicsFormat.R_BC4_UNorm:
				case GraphicsFormat.R_BC4_SNorm:
				case GraphicsFormat.RG_BC5_UNorm:
				case GraphicsFormat.RG_BC5_SNorm:
				case GraphicsFormat.RGB_BC6H_UFloat:
				case GraphicsFormat.RGB_BC6H_SFloat:
				case GraphicsFormat.RGB_PVRTC_2Bpp_SRGB:
				case GraphicsFormat.RGB_PVRTC_2Bpp_UNorm:
				case GraphicsFormat.RGB_PVRTC_4Bpp_SRGB:
				case GraphicsFormat.RGB_PVRTC_4Bpp_UNorm:
				case GraphicsFormat.RGB_ETC_UNorm:
				case GraphicsFormat.RGB_ETC2_SRGB:
				case GraphicsFormat.RGB_ETC2_UNorm:
				case GraphicsFormat.R_EAC_UNorm:
				case GraphicsFormat.R_EAC_SNorm:
				case GraphicsFormat.RG_EAC_UNorm:
				case GraphicsFormat.RG_EAC_SNorm:
				case GraphicsFormat.YUV2:
				case GraphicsFormat.D16_UNorm_S8_UInt:
					return false;
				default:
					throw new ArgumentOutOfRangeException(
						$"Graphicsformat: {nameof(format)} is not implemented\n {format}");
			}
		}
	}
}