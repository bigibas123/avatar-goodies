using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

namespace Characters.Common.Editor.Tools.TextureArrayCreator
{
    [CreateAssetMenu(fileName = "Texture Array Container", menuName = "Bigi/Texture Array Container", order = 3)]
    public class TextureArrayContainer : ScriptableObject
    {
        [SerializeField] public FilterMode filterMode;
        [SerializeField] public TextureWrapMode wrapMode;
        [SerializeField] public List<Texture2D> textures;
        [SerializeField] public TextureCreationFlags flags;

        public int Width => (textures[0] != null ? textures[0]?.width : null) ?? 0;
        public int Height => (textures[0] != null ? textures[0]?.height : null) ?? 0;
        public int Depth => textures?.Count(p => { return p != null;}) ?? 0;

        public int MipCount => (textures[0] != null ? textures[0]?.mipmapCount : null) ?? 0;
        
        public GraphicsFormat graphicsFormat => (textures[0] != null ? textures[0]?.graphicsFormat : null) ?? GraphicsFormat.None;
        

        public override string ToString()
        {
            return base.ToString() + AssetDatabase.GetAssetPath(MonoScript.FromScriptableObject(this));
        }
        public Texture2DArray ToArray()
        {
            if (Depth <= 0)
            {
                Debug.LogError("Attempted generation of empty TextureArray: " + this);
                return null;
            }
            if (!SystemInfo.IsFormatSupported(graphicsFormat,FormatUsage.Sample))
            {
                Debug.LogError("Attempted generation of TextureArray with wrong graphicsFormat, please use a different one: " + this);
                return null;
            }
            Texture2DArray array = new Texture2DArray(Width, Height, Depth, graphicsFormat, flags, MipCount)
            {
                filterMode = filterMode,
                wrapMode = wrapMode,
            };

            TextureImporterSettings[] oldSettings = new TextureImporterSettings[textures.Count];
            int curTexNumber = 0;
            for (int texIdx = 0; texIdx < textures.Count; texIdx++)
            {
                var tex = textures[texIdx];
                if (tex == null) {continue;}

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
                        importer.maxTextureSize = Math.Max(Width,Height);
                        EditorUtility.SetDirty(importer);
                        importer.SaveAndReimport();
                    }

                    for (int mipMapLevel = 0; mipMapLevel < array.mipmapCount; mipMapLevel++)
                    {
                        array.SetPixelData(tex.GetRawTextureData<ulong>(), mipMapLevel, curTexNumber++);

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
    }
}