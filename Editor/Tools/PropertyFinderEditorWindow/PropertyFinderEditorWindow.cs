// MIT License
//
// Copyright (c) 2022 Haï~ (@vr_hai github.com/hai-vr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if UNITY_EDITOR
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Hai.PropertyFinder.Scripts.Editor
{
    public class PropertyFinderEditorWindow : EditorWindow
    {
        public GameObject targetObject;

        private string _search;
        private Vector2 _scrollPos;
        private bool _focusNext;
        private static readonly string[] ColorKeywords = {"color", "colour", "tint"};

        private void OnGUI()
        {
            var serializedObject = new SerializedObject(this);
            EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(targetObject)));
            serializedObject.ApplyModifiedProperties();

            var rootObject = targetObject;

            GUI.SetNextControlName("search");
            _search = EditorGUILayout.TextField("Search", _search);
            if (_focusNext)
            {
                _focusNext = false;
                EditorGUI.FocusTextInControl("search");
            }

            var hasSearch = !string.IsNullOrEmpty(_search);

            _scrollPos = GUILayout.BeginScrollView(_scrollPos, GUILayout.Height(Screen.height - EditorGUIUtility.singleLineHeight * 4));

            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

            if (targetObject == null)
            {
                GUILayout.EndScrollView();
                return;
            }

            var bindings = AnimationUtility.GetAnimatableBindings(targetObject, rootObject ? rootObject : targetObject);
            if (hasSearch)
            {
                var matches = bindings.Where(IsMatch).Count();
                EditorGUILayout.LabelField($"{matches} result{(matches > 1 ? "s" : "")} ({bindings.Length - matches} hidden)");
            }
            else
            {
                EditorGUILayout.LabelField($"{bindings.Length} result{(bindings.Length > 1 ? "s" : "")}");
            }

            var animatorRootObject = targetObject.GetComponentInParent<Animator>();
            var transformPath = AnimationUtility.CalculateTransformPath(targetObject.transform, animatorRootObject == null ? targetObject.transform : animatorRootObject.transform);
            EditorGUI.BeginDisabledGroup(transformPath.Length == 0);
            EditorGUILayout.TextField("Path", transformPath);
            EditorGUI.EndDisabledGroup();

            foreach (var typeToBinding in bindings.GroupBy(binding => binding.type))
            {
                if (hasSearch && !typeToBinding.Any(IsMatch)) continue;

                GUILayout.BeginVertical("GroupBox");
                var targetedType = typeToBinding.Key;
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.TextField(targetedType.Name, EditorStyles.label);
                if (typeof(Component).IsAssignableFrom(targetedType))
                {
                    EditorGUILayout.ObjectField(targetObject.GetComponent(targetedType), targetedType);
                }
                else if (targetedType == typeof(GameObject))
                {
                    EditorGUILayout.ObjectField(targetObject, typeof(GameObject));
                }
                else
                {
                    EditorGUILayout.TextField(targetedType.Name);
                }
                EditorGUILayout.EndHorizontal();
                foreach (var binding in typeToBinding)
                {
                    if (!hasSearch || IsMatch(binding))
                    {
                        var property = binding.propertyName;
                        DisplayColor(property, binding, rootObject);

                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.TextField(property);
                        var success = AnimationUtility.GetFloatValue(rootObject, binding, out var floatValue);
                        if (success)
                        {
                            EditorGUILayout.FloatField(floatValue, GUILayout.Width(50));
                        }
                        else
                        {
                            success = AnimationUtility.GetObjectReferenceValue(rootObject, binding, out var objectValue);
                            if (success && objectValue != null && objectValue is Object)
                            {
                                EditorGUILayout.ObjectField(objectValue, typeof(Object), GUILayout.Width(100));
                            }
                        }
                        EditorGUILayout.EndHorizontal();
                    }
                }
                GUILayout.EndVertical();
            }
            GUILayout.EndScrollView();
        }

        private void DisplayColor(string property, EditorCurveBinding binding, GameObject rootObject)
        {
            var propertyLowercase = property.ToLowerInvariant();
            if (property.EndsWith(".x") && HasColorKeyword(propertyLowercase))
            {
                var start = property.Substring(0, property.Length - 2);
                var hasX = AnimationUtility.GetFloatValue(rootObject, new EditorCurveBinding {path = binding.path, propertyName = start + ".x", type = binding.type}, out var x);
                var hasY = AnimationUtility.GetFloatValue(rootObject, new EditorCurveBinding {path = binding.path, propertyName = start + ".y", type = binding.type}, out var y);
                var hasZ = AnimationUtility.GetFloatValue(rootObject, new EditorCurveBinding {path = binding.path, propertyName = start + ".z", type = binding.type}, out var z);
                var hasW = AnimationUtility.GetFloatValue(rootObject, new EditorCurveBinding {path = binding.path, propertyName = start + ".w", type = binding.type}, out var w);
                if (hasX && hasY && hasZ)
                {
                    EditorGUILayout.BeginHorizontal();
                    EditorGUI.BeginDisabledGroup(true);
                    EditorGUILayout.TextField(start);
                    EditorGUI.EndDisabledGroup();
                    if (hasW)
                    {
                        EditorGUILayout.ColorField(GUIContent.none, new Color(x, y, z, w), false, true, true, GUILayout.Width(50));
                    }
                    else
                    {
                        EditorGUILayout.ColorField(GUIContent.none, new Color(x, y, z), false, false, true, GUILayout.Width(50));
                    }

                    EditorGUILayout.EndHorizontal();
                }
            }

            if (property.EndsWith(".r"))
            {
                var start = property.Substring(0, property.Length - 2);
                var hasR = AnimationUtility.GetFloatValue(rootObject, new EditorCurveBinding {path = binding.path, propertyName = start + ".r", type = binding.type}, out var r);
                var hasG = AnimationUtility.GetFloatValue(rootObject, new EditorCurveBinding {path = binding.path, propertyName = start + ".g", type = binding.type}, out var g);
                var hasB = AnimationUtility.GetFloatValue(rootObject, new EditorCurveBinding {path = binding.path, propertyName = start + ".b", type = binding.type}, out var b);
                var hasA = AnimationUtility.GetFloatValue(rootObject, new EditorCurveBinding {path = binding.path, propertyName = start + ".a", type = binding.type}, out var a);
                if (hasR && hasG && hasB)
                {
                    EditorGUILayout.BeginHorizontal();
                    EditorGUI.BeginDisabledGroup(true);
                    EditorGUILayout.TextField(start);
                    EditorGUI.EndDisabledGroup();
                    EditorGUILayout.ColorField(GUIContent.none, hasA ? new Color(r, g, b, a) : new Color(r, g, b), false, hasA, false, GUILayout.Width(50));
                    EditorGUILayout.EndHorizontal();
                }
            }
        }

        private static bool HasColorKeyword(string propertyLowercase)
        {
            return ColorKeywords.Any(keyword => propertyLowercase.Contains(keyword));
        }

        private bool IsMatch(EditorCurveBinding editorCurveBinding)
        {
            var propertyName = editorCurveBinding.propertyName.ToLowerInvariant();
            return _search.ToLowerInvariant().Split(' ').All(needle => propertyName.Contains(needle));
        }

        private void UsingTarget(Transform newTarget)
        {
            targetObject = newTarget.gameObject;
            // var anyRoot = newTarget.GetComponentInParent<Animator>();
            // animatorRootObject = anyRoot != null ? anyRoot.gameObject : targetObject;

            _focusNext = true;
        }

        [MenuItem("Window/Haï/PropertyFinder")]
        public static void ShowWindow()
        {
            Obtain().Show();
        }

        [MenuItem("CONTEXT/Transform/Haï PropertyFinder")]
        public static void OpenEditor(MenuCommand command)
        {
            var window = Obtain();
            window.UsingTarget((Transform) command.context);
            window.Show();
            window.Focus();
        }

        private static PropertyFinderEditorWindow Obtain()
        {
            var editor = GetWindow<PropertyFinderEditorWindow>(false, null, false);
            editor.titleContent = new GUIContent("PropertyFinder");
            return editor;
        }
    }
}
#endif