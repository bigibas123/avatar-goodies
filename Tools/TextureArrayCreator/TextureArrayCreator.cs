using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditorInternal;

namespace MK.Utilities
{
	public class TextureArrayCreator : ScriptableWizard
	{
		[MenuItem("Window/Texture Array Creator")]
		public static void ShowWindow()
		{
			ScriptableWizard.DisplayWizard<TextureArrayCreator>("Create Texture Array", "Build Asset");
		}

		public string path = "Assets/";
		public string filename = "MyTextureArray";

		public List<Texture2D> textures = new List<Texture2D>();

		private ReorderableList list;

		void OnWizardCreate()
		{
			CompileArray(textures, path, filename);
		}

		private void CompileArray(List<Texture2D> textures, string path, string filename)
		{
			if(textures == null || textures.Count == 0)
			{
				Debug.LogError("No textures assigned");
				return;
			}

			Texture2D sample = textures[0];
			Texture2DArray textureArray = new Texture2DArray(sample.width, sample.height, textures.Count, sample.format, false);
			textureArray.filterMode = FilterMode.Trilinear;
			textureArray.wrapMode = TextureWrapMode.Repeat;

			for (int i = 0; i < textures.Count; i++)
			{
				Texture2D tex = textures[i];
				textureArray.SetPixels(tex.GetPixels(0), i, 0);
			}
			textureArray.Apply();
			
			string uri = path + filename+".asset";
			AssetDatabase.CreateAsset(textureArray, uri);
			Debug.Log("Saved asset to " + uri);
		}
	}
}