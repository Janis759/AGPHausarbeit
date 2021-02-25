using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Particle : MonoBehaviour
{
    private ShaderCom raymarcher;


    private void Start()
    {
        raymarcher = FindObjectOfType<ShaderCom>();  
    }

    private void Update()
    {
        if(transform.position.x < -5)
        {
            gameObject.SetActive(false);
            raymarcher.splashEvent.Invoke(transform.position, Wall.Right);
        }
        else if (transform.position.y < -5)
        {
            gameObject.SetActive(false);
            raymarcher.splashEvent.Invoke(transform.position, Wall.Bottom);
        }
        else if (transform.position.z < -5)
        {
            gameObject.SetActive(false);
            raymarcher.splashEvent.Invoke(transform.position, Wall.Left);

        }
    }
}
