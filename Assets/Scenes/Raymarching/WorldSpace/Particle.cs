using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Particle : MonoBehaviour
{
    private TestPos raymarcher;


    private void Start()
    {
        raymarcher = FindObjectOfType<TestPos>();  
    }

    private void OnTriggerExit(Collider other)
    {
        if(other.gameObject.CompareTag("Wall"))
        {
            gameObject.SetActive(false);
            //raymarcher.splashEvent.Invoke(transform.position);
        }
    }
}
