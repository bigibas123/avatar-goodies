using UnityEngine;
using UnityEditor;
using System;
using System.IO;

/// <summary>
/// Unity package helper. Provides Menu options for automatically importing and 
/// exporting multiple Unity packages.
/// Auth: Isaac Dart; 2018-09-17
///
/// Gotten from: https://discussions.unity.com/t/is-it-possible-to-import-more-than-one-asset-package-at-the-same-time/28492/4
/// </summary>
public class UnityPackageHelper
{
	static int successCount = 0;

	[MenuItem("Tools/Unity Packages/Import Folder", false, 7)]
	public static void ImportPackagesFromFolder()
	{
		string pPath = "";
		successCount = 0;
		pPath = EditorUtility.OpenFolderPanel("Select Package Path", Application.dataPath, "");

		if (!String.IsNullOrEmpty(pPath))
		{
			string[] files = Directory.GetFiles(pPath, "*.unitypackage");

			if (files != null && files.Length > 0)
			{
				AssetDatabase.importPackageCompleted += PackageImportSuccess;
				AssetDatabase.importPackageFailed += PackageImportFail;
				for (int i = 0; i < files.Length; i++)
				{
					string packagePath = files[i];

					AssetDatabase.ImportPackage(packagePath, false);
				}

				AssetDatabase.importPackageCompleted -= PackageImportSuccess;
				AssetDatabase.importPackageFailed -= PackageImportFail;

				Debug.Log("Import complete. " + successCount + " of " + files.Length + " packages successfully imported.");
			}
		}
	}

	static void PackageImportSuccess(string packageName)
	{
		successCount++;
		Debug.Log("Completed import of package '" + packageName + "'");
	}

	static void PackageImportFail(string packageName, string errorMessage)
	{
		Debug.Log("Failed to import package '" + packageName + "’ with error message '"+errorMessage + "'.");
	}

	[MenuItem("Tools/Unity Packages/Export To Folder", false, 7)]

	public static void ExportSelectionAsPackages()
	{
		string pPath = "";
		successCount = 0;
		pPath = EditorUtility.OpenFolderPanel("Select Package Export Path", Application.dataPath, "");

		if (!String.IsNullOrEmpty(pPath))
		{
			GameObject[] selected = Selection.gameObjects;

			if (selected != null && selected.Length > 0)
			{
				for (int i = 0; i < selected.Length; i++)
				{
					GameObject transToPackage = selected[i];
						string assetPath = AssetDatabase.GetAssetPath(transToPackage.GetInstanceID());
					if (String.IsNullOrEmpty(assetPath)) continue;
					string exportPath = pPath + "/" +transToPackage.name + ".unitypackage";
					Debug.Log(String.Format("Exporting ‘{0}’ to ‘{1}’ …", assetPath, exportPath));
					AssetDatabase.ExportPackage(assetPath, exportPath, ExportPackageOptions.IncludeDependencies);
					successCount++;
				}

				if (successCount == 0)
				{
					Debug.Log("No objects were selected in the project view.");
				}
				else
				{
					Debug.Log("Export complete. " + successCount + " of " + selected.Length + " selected objects successfully exported.");
				}
			}
			else
			{
				Debug.Log("Nothing selected to export.");
			}
		}
	}
}