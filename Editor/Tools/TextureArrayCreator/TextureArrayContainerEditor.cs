using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Characters.Common.Editor.Tools.TextureArrayCreator
{
    [CustomEditor(typeof(TextureArrayContainer))]
    public class TextureArrayContainerEditor : UnityEditor.Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            if (GUILayout.Button("Generate"))
            {
                var tac = serializedObject.targetObject as TextureArrayContainer;
                string path = AssetDatabase.GetAssetPath(tac);
                string fixedPath = path.Replace(".asset", "TC.asset");
                if (tac != null)
                {
                    var arr = tac.ToArray();
                    AssetDatabase.CreateAsset(arr, fixedPath);
                    Debug.Log("Saved asset to " + fixedPath);
                }
                else
                {
                    Debug.LogError("Tac is null:"+this);
                }
            }
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
            foreach (var texContainer in FindAssetsByType<TextureArrayContainer>())
            {
                string path = AssetDatabase.GetAssetPath(texContainer);
                string fixedPath = path.Replace(".asset", "TC.asset");
                var arr = texContainer.ToArray();
                AssetDatabase.CreateAsset(arr, fixedPath);
                Debug.Log("Saved asset to " + fixedPath);
            }
        }
    }
}