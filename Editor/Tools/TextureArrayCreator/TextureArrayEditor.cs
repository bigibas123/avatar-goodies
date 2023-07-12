using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

namespace tk.dingemans.bigibas123.unity
{

    [CreateAssetMenu(fileName = "Texture Array Container", menuName = "Bigi/Texture Array Container", order = 3)]
    public class TextureArrayContainer : ScriptableObject
    {
        [SerializeField] public List<Texture2D> textures;
        [SerializeField] public TextureCreationFlags flags;

        private int width => textures[0]?.width ?? 0;
        private int height => textures[0]?.height ?? 0;

        private int mipCount => textures[0]?.mipmapCount ?? 0;
        private FilterMode filterMode => textures[0]?.filterMode ?? FilterMode.Bilinear;
        private TextureWrapMode wrapMode => textures[0]?.wrapMode ?? TextureWrapMode.Repeat;
        private int depth => textures.Count;

        private GraphicsFormat graphicsFormat => textures[0]?.graphicsFormat ?? GraphicsFormat.None;

        public override string ToString()
        {
            return base.ToString() + AssetDatabase.GetAssetPath(MonoScript.FromScriptableObject(this));
        }
        private Texture2DArray ToArray()
        {
            if (depth <= 0)
            {
                Debug.LogError("Attempted generation of empty TextureArray: " + this);
                return null;
            }
            Texture2DArray array = new Texture2DArray(width, height, depth, graphicsFormat, flags, mipCount)
            {
                filterMode = filterMode,
                wrapMode = wrapMode,
            };

            TextureImporterSettings[] oldSettings = new TextureImporterSettings[textures.Count];

            for (int texIdx = 0; texIdx < textures.Count; texIdx++)
            {
                var tex = textures[texIdx];

                if (tex.width == array.width && tex.height == array.height)
                {
                    if (!tex.isReadable)
                    {
                        string path = AssetDatabase.GetAssetPath(tex);
                        var importer = (TextureImporter)AssetImporter.GetAtPath(path);
                        oldSettings[texIdx] = new TextureImporterSettings();
                        importer.ReadTextureSettings(oldSettings[texIdx]);
                        Debug.Log("Setting isReadable to true for: " + path);
                        importer.isReadable = true;
                        EditorUtility.SetDirty(importer);
                        importer.SaveAndReimport();
                    }

                    for (int mipMapLevel = 0; mipMapLevel < array.mipmapCount; mipMapLevel++)
                    {
                        array.SetPixelData(tex.GetRawTextureData<ulong>(),mipMapLevel,texIdx);
                        
                        //array.SetPixels(tex.GetPixels(mipMapLevel), texIdx, mipMapLevel);
                    }
                }
                else
                {
                    throw new UnityException($"Texture: {tex.name} not the right size or format: ({tex.width}x{tex.height}@{tex.graphicsFormat}) array: {array.width}x{array.height}@{array.graphicsFormat})");
                }

            }
            array.Apply(true, true);
            for (int texIdx = 0; texIdx < textures.Count; texIdx++)
            {
                if (oldSettings[texIdx] == null)
                {
                    continue;
                }
                var tex = textures[texIdx];
                string path = AssetDatabase.GetAssetPath(tex);
                var importer = (TextureImporter)AssetImporter.GetAtPath(path);
                importer.SetTextureSettings(oldSettings[texIdx]);
                EditorUtility.SetDirty(importer);
                importer.SaveAndReimport();
            }
            return array;
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
        private static void Open()
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