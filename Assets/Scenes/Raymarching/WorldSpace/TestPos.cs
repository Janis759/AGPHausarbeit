using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestPos : MonoBehaviour
{
    public PoolParticleSystem pps;
    public Transform cam;

    public Material mat;

    void Update()
    {
        mat.SetVectorArray("positions", pps.GetArray());
    }
}
