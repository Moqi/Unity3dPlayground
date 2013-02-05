using UnityEngine;
using System.Collections;

public class BigBall : MonoBehaviour {

	
 	void OnCollisionEnter(Collision collision) {
		gameObject.GetComponent<AudioSource>().Play();
    }
}
