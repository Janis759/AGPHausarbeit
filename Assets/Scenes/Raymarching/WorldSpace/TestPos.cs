using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TestPos : MonoBehaviour
{
    private PoolParticleSystem pps;

    public Material mat;
    public Color slimeColor, wallColor;
    public Transform pointLight;
    public float slimeSphereRadius;
    public float smoothness;

    private void Start()
    {
        pps = FindObjectOfType<PoolParticleSystem>();
    }

    void Update()
    {
        mat.SetVectorArray("positions", pps.GetArray());
        mat.SetVector("slimecolor", slimeColor);
        mat.SetVector("wallcolor", wallColor);
        mat.SetVector("lightPosition", pointLight.position);
        mat.SetFloat("sphereRadius", slimeSphereRadius);
        mat.SetFloat("smoothness", smoothness);
    }
}
