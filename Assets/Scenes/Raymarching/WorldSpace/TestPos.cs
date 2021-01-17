using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TestPos : MonoBehaviour
{
    private PoolParticleSystem pps;

    public Material mat;
    public Color slimeColor, wallColor;
    public Transform directionalLight;
    public float slimeSphereRadius;
    public float smoothness;
    public float lightIntensity, shadowIntesity;
    [Range(0,128)]
    public float shadowPenumbra;
    public Vector2 shadowDistance;

    private void Start()
    {
        pps = FindObjectOfType<PoolParticleSystem>();
    }

    void Update()
    {
        mat.SetVectorArray("positions", pps.GetArray());
        mat.SetVector("slimecolor", slimeColor);
        mat.SetVector("wallcolor", wallColor);
        mat.SetVector("lightDirection", directionalLight ? directionalLight.forward : Vector3.down);
        mat.SetFloat("sphereRadius", slimeSphereRadius);
        mat.SetFloat("smoothness", smoothness);
        mat.SetFloat("lightIntesity", lightIntensity);
        mat.SetFloat("shadowIntencity", shadowIntesity);
        mat.SetFloat("shadowPenumbra", shadowPenumbra);
        mat.SetVector("shadowDistance", shadowDistance);
    }
}
