using UnityEngine;
using System.Collections;

public class BigBall : MonoBehaviour {

	
 	void OnCollisionEnter(Collision collision) {
		if(collision.gameObject.tag == "Projectile")
		{
			gameObject.GetComponent<AudioSource>().Play();
			Destroy(collision.gameObject);
		}
    }
}
