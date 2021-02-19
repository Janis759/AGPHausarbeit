using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LightToggle : MonoBehaviour
{
    Toggle m_Toggle;
    public Material mat;
    public enum LightType
    {
        Ambient, 
        Diffuse, 
        Specular
    };
    public LightType lightType = LightType.Ambient;
    
    // Start is called before the first frame update
    void Start()
    {
        m_Toggle = GetComponent<Toggle>();
        m_Toggle.onValueChanged.AddListener(delegate {
            ToggleValueChanged(m_Toggle);
        });
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void ToggleValueChanged(Toggle change)
    {
        if (lightType.Equals(LightType.Ambient))
        {
            mat.SetFloat("_IS_AMBIENT", change.isOn ? 1 : 0);
        }
        else if (lightType.Equals(LightType.Diffuse))
        {
            mat.SetFloat("_IS_DIFFUSE", change.isOn ? 1 : 0);
        }
        else if (lightType.Equals(LightType.Specular))
        {
            mat.SetFloat("_IS_SPECULAR", change.isOn ? 1 : 0);
        }
    }
}
