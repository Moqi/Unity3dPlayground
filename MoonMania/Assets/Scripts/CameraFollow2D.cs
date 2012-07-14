using UnityEngine;
using System.Collections;

public class CameraFollow2D : MonoBehaviour 
{
	public GameObject Target;
	public float ZPosition = -5f;
	
	// Update is called once per frame
	void Update () 
	{
		var position = new Vector3(Target.transform.position.x,
								   Target.transform.position.y,
								   ZPosition);
		transform.position = position;
	}
}
