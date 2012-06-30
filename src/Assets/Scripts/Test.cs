using UnityEngine;
using System.Collections;

public class Test : MonoBehaviour {
	
	public float Speed;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		var atmToMove = Speed * Time.deltaTime;
		
		if(Input.GetKey(KeyCode.A))
			transform.Translate(Vector3.left * atmToMove);
		else if(Input.GetKey(KeyCode.D))
			transform.Translate(Vector3.right * atmToMove);
		
		if(Input.GetKey(KeyCode.S))
			transform.Translate(Vector3.back * atmToMove);
		else if(Input.GetKey(KeyCode.W))
			transform.Translate(Vector3.forward * atmToMove);
		
		
		if(Input.GetKeyDown(KeyCode.Escape))
			Application.Quit();
		
		Debug.Log(Screen.width + " - " + Screen.height +" amToMove: " +atmToMove);
	}
	
	void OnGui()
	{
		
	}
}
