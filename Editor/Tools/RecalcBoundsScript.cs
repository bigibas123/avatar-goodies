using UnityEditor;
using UnityEngine;

public class RecalcBoundsScript
{

	// Adding a new context menu item
	[MenuItem("GameObject/Update bounds", true)]
	static bool CheckIfRenderer()
	{
		// disable menu item if no transform is selected.
		return Selection.activeTransform != null && (
			Selection.activeTransform.GetComponentInChildren<SkinnedMeshRenderer>() != null
			|| Selection.activeTransform.GetComponentInChildren<MeshFilter>());
	}
	// Put menu item at top near other "Create" options
	[MenuItem("GameObject/Update bounds", false, 0)] //10
	private static void RecalcBounds(MenuCommand menuCommand)
	{
		// Use selected item as our context (otherwise does nothing because of above)
		//GameObject selected = menuCommand.context as GameObject;
		var smrs = Selection.activeTransform.GetComponentsInChildren<SkinnedMeshRenderer>(true);
		var mrs = Selection.activeTransform.GetComponentsInChildren<MeshRenderer>(true);
		var mfs = Selection.activeTransform.GetComponentsInChildren<MeshFilter>(true);
		int smrCount = 0;
		int mrCount = 0;
		int mfCount = 0;
		foreach (var smr in smrs)
		{
			if (smr.sharedMesh != null)
			{
				smr.sharedMesh.RecalculateBounds();
			}
			smr.ResetBounds();
			smr.ResetLocalBounds();
			smrCount++;
		}
		foreach (var mr in mrs)
		{
			mr.ResetBounds();
			mr.ResetLocalBounds();
			mrCount++;
		}

		foreach (var mf in mfs)
		{
			if (mf.sharedMesh != null)
			{
				mf.sharedMesh.RecalculateBounds();
			}
			mfCount++;
		}
 
		// Yea!
		Debug.Log($"Recalculated bounds for {Selection.activeTransform.gameObject.name}. Skinned: {smrCount}, Static: {mrCount}, Filter: {mfCount}");
	}
}
