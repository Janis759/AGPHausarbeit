using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class SplashEvent : UnityEvent<Vector3> { }

[ExecuteInEditMode]
public class TestPos : MonoBehaviour
{
    private PoolParticleSystem pps;

    public SplashEvent splashEvent;

    public Material mat;
    public Color slimeColor, wallColor;
    public Transform directionalLight;
    public float slimeSphereRadius;
    public float smoothness;
    public float lightIntensity, shadowIntesity;
    [Range(0,128)]
    public float shadowPenumbra;
    public Vector2 shadowDistance;
    public Texture2D splashTex;

    public Texture2D texture;

    private void Start()
    {
        pps = FindObjectOfType<PoolParticleSystem>();
        //texture = CreateTexture();
        Debug.Log(texture.width);
        if (splashEvent == null)
            splashEvent = new SplashEvent();

        splashEvent.AddListener(SplashEventHandler);
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
        mat.SetTexture("wallTexture", texture);
    }

    Texture2D CreateTexture()
    {
        Texture2D texture = new Texture2D(1080, 1080, TextureFormat.RGB24, false);

        Color[] pixels = texture.GetPixels();

        for (int i = 0; i < pixels.Length; i++)
        {
            pixels[i] = wallColor;
        }

        texture.SetPixels(pixels);
        texture.Apply();

        return texture;
    }

    private void SplashEventHandler(Vector3 pos)
    {
        Debug.Log(pos);
        Vector2 position = new Vector2(pos.x, pos.z) / transform.localScale.x;
        position += new Vector2(0.5f, 0.5f);
        texture = AddSplash(texture, position);
    }

    Texture2D AddSplash(Texture2D main, Vector2 pos)
    {
        int startX = (int)(pos.x * main.width);
        int startY = (int)(pos.y * main.height);

        Texture2D rSplashTex = rotateTexture(splashTex, Random.Range(0, 360));

        for (int x = 0; x < splashTex.width; x++)
        {
            for (int y = 0; y < splashTex.height; y++)
            {
                Color bgColor = main.GetPixel(startX + x, startY + y);
                Color sColor = rSplashTex.GetPixel(x, y);
                if (sColor.a != 0)
                    sColor = slimeColor;

                Color fColor = Color.Lerp(bgColor, sColor, sColor.a / 1.0f);

                main.SetPixel(startX + x, startY + y, fColor);
            }
        }

        main.Apply();
        return main;
    }
#region Quelle: https://forum.unity.com/threads/rotate-a-texture-with-an-arbitrary-angle.23904/ (User: raleighr3)
    Texture2D rotateTexture(Texture2D tex, float angle)
    {
        Texture2D rotImage = new Texture2D(tex.width, tex.height);
        int x, y;
        float x1, y1, x2, y2;

        int w = tex.width;
        int h = tex.height;
        float x0 = rot_x(angle, -w / 2.0f, -h / 2.0f) + w / 2.0f;
        float y0 = rot_y(angle, -w / 2.0f, -h / 2.0f) + h / 2.0f;

        float dx_x = rot_x(angle, 1.0f, 0.0f);
        float dx_y = rot_y(angle, 1.0f, 0.0f);
        float dy_x = rot_x(angle, 0.0f, 1.0f);
        float dy_y = rot_y(angle, 0.0f, 1.0f);


        x1 = x0;
        y1 = y0;

        for (x = 0; x < tex.width; x++)
        {
            x2 = x1;
            y2 = y1;
            for (y = 0; y < tex.height; y++)
            {
                //rotImage.SetPixel (x1, y1, Color.clear);          

                x2 += dx_x;//rot_x(angle, x1, y1);
                y2 += dx_y;//rot_y(angle, x1, y1);
                rotImage.SetPixel((int)Mathf.Floor(x), (int)Mathf.Floor(y), getPixel(tex, x2, y2));
            }

            x1 += dy_x;
            y1 += dy_y;

        }

        rotImage.Apply();
        return rotImage;
    }

    private Color getPixel(Texture2D tex, float x, float y)
    {
        Color pix;
        int x1 = (int)Mathf.Floor(x);
        int y1 = (int)Mathf.Floor(y);

        if (x1 > tex.width || x1 < 0 ||
           y1 > tex.height || y1 < 0)
        {
            pix = Color.clear;
        }
        else
        {
            pix = tex.GetPixel(x1, y1);
        }

        return pix;
    }

    private float rot_x(float angle, float x, float y)
    {
        float cos = Mathf.Cos(angle / 180.0f * Mathf.PI);
        float sin = Mathf.Sin(angle / 180.0f * Mathf.PI);
        return (x * cos + y * (-sin));
    }
    private float rot_y(float angle, float x, float y)
    {
        float cos = Mathf.Cos(angle / 180.0f * Mathf.PI);
        float sin = Mathf.Sin(angle / 180.0f * Mathf.PI);
        return (x * sin + y * cos);
    }
    #endregion
}
