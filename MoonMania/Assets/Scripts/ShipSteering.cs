using UnityEngine;
using System.Collections;

public class ShipSteering : MonoBehaviour 
{
	public float RotationSpeed;
	public float ThrustForce;
	public GameObject LaserProjectile;
	
	// Use this for initialization
	void Start () 
	{
	
	}
	
	// Update is called once per frame
	void Update () 
	{
		//Steering
		var amtToMove = ThrustForce * Input.GetAxis("Vertical") * Time.deltaTime;
		var rotation = RotationSpeed * Input.GetAxis("Horizontal") * Time.deltaTime;
		this.rigidbody.AddForce(transform.up * amtToMove, ForceMode.Force);
		this.rigidbody.freezeRotation = true;
		this.transform.Rotate(Vector3.back * rotation, Space.World);
		
		//Fire laser
		if(Input.GetKeyDown(KeyCode.Space))
		{
			var position = transform.TransformPoint(Vector3.up * 1f);
			var laserProjectile = (GameObject) Instantiate(LaserProjectile, position, transform.localRotation);
			laserProjectile.rigidbody.AddRelativeForce(Vector3.up * 200f); 
			
			Destroy(laserProjectile, 5f);
		}
		
	}
}
