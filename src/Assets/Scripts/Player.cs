using UnityEngine;
using System.Collections;

public class Player : MonoBehaviour {

	public GameObject Projectile;
	public GameObject ProjectileSpawnPosition;
	
	// Update is called once per frame
	void Update () 
	{
		if(Input.GetKeyDown(KeyCode.Space))
		{
			GameObject projectile = (GameObject)Instantiate(Projectile, ProjectileSpawnPosition.transform.position, Quaternion.identity);	
			projectile.rigidbody.AddForce(transform.forward * 1000);
		}
	}
}
