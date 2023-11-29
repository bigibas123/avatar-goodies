using UnityEditor;
using UnityEngine;

namespace Characters.Common.Editor.Tools.BigiShaderEditor
{
    public class BigiShaderEditor : ShaderGUI 
    {
        public override void OnGUI (MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            // Custom code that controls the appearance of the Inspector goes here

            base.OnGUI (materialEditor, properties);
            EditorGUI.indentLevel++;
            bool emissionEnabled = materialEditor.EmissionEnabledProperty();
            materialEditor.LightmapEmissionFlagsProperty(0,emissionEnabled,true);
            EditorGUI.indentLevel--;

        }
    }
}