using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

namespace Characters.Common.Editor.Tools.TextureArrayCreator
{
    [CustomEditor(typeof(TextureArrayContainer))]
    public class TextureArrayContainerEditor : UnityEditor.Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            var tac = serializedObject.targetObject as TextureArrayContainer;
            if (GUILayout.Button("Generate"))
            {
                if (tac != null)
                {
                    try
                    {
                        AssetDatabase.DisallowAutoRefresh();
                        tac.SaveToFile();
                    }
                    finally
                    {
                        AssetDatabase.AllowAutoRefresh();
                    }
                }
                else
                {
                    Debug.LogError("Tac is null:" + this);
                }
            }
            GUILayout.Label("Width: " + tac.Width);
            GUILayout.Label("Height: "+ tac.Height);
            GUILayout.Label("Depth: " + tac.Depth);
            GUILayout.Label("Mipmaps: "+ tac.MipCount);
            GUILayout.Label("Format: "+ tac.GraphicsFormat);
           
        }
        private static IEnumerable<T> FindAssetsByType<T>() where T : UnityEngine.Object
        {
            string[] guids = AssetDatabase.FindAssets($"t:{typeof(T)}");
            foreach (string t in guids)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(t);
                var asset = AssetDatabase.LoadAssetAtPath<T>(assetPath);
                if (asset != null)
                {
                    yield return asset;
                }
            }
        }



        [MenuItem("Tools/Convert all TextureArrays")]
        private static void ConvertAll()
        {
            try
            {
                AssetDatabase.DisallowAutoRefresh();
                foreach (var texContainer in FindAssetsByType<TextureArrayContainer>())
                {
                    texContainer.SaveToFile();
                }
            }
            finally
            {
                AssetDatabase.AllowAutoRefresh();
            }
        }
    }
}