using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Marker : MonoBehaviour
{
    public Transform outline;
    public float scale = 1;

    void Update()
    {
        outline.localScale = new Vector3(scale, scale, scale)*4;
    }
}
