using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TestPos : MonoBehaviour
{
    public Transform pos1;
    public Transform pos2;
    public Transform cam;

    public Material mat;
    void Update()
    {
        Vector4[] positions = new Vector4[]
        {
            -pos1.position, -pos2.position
        };
        mat.SetVectorArray("positions", positions);

        cam.LookAt(pos1);
    }

}
