using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderAnimation : MonoBehaviour
{
    Material mat;

    private void Start()
    {
        mat = GetComponent<Renderer>().sharedMaterial;
    }

    void Update()
    {
        float morph = Mathf.Sin(Time.time) / 2 + .5f;
        mat.SetFloat("_MORPH_STATE", morph);
    }
}
