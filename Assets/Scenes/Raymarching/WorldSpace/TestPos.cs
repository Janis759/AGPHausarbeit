using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine;
using UnityEngine.Events;

public class SplashEvent : UnityEvent<Vector3, Wall> { }

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
        texture = CreateTexture();
        Debug.Log(texture.width);
        if (splashEvent == null)
            splashEvent = new SplashEvent();

        splashEvent.AddListener(SplashEventHandler);

        //AddSplash(texture, new Vector2(.25f, .25f), -1);

    
        Image previewTexture = GameObject.Find("PreviewTexture").GetComponent<Image>();
        previewTexture.material.mainTexture = texture;
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
        texture.wrapMode = TextureWrapMode.Clamp;

        Color[] pixels = texture.GetPixels();

        for (int i = 0; i < pixels.Length; i++)
        {
            pixels[i] = wallColor;
        }

        texture.SetPixels(pixels);
        texture.Apply();

        for (int x = 0; x < texture.width; x++)
        {
            for (int y = 0; y < texture.height; y++)
            {
                if (x == texture.width / 2 || y == texture.height / 2 || 
                    x == texture.width / 2 - 1 || y == texture.height / 2 - 1 
                    ||  x == texture.width / 2 + 1 || y == texture.height / 2 + 1)
                {
                    Color color = Color.blue;
                    if (x > texture.width / 2 && y <= texture.height / 2 + 1 && y >= texture.height / 2 - 1) {
                        color = Color.red;
                    }else if (y < texture.height / 2 - 1) {
                        color = Color.green;
                    }
                    texture.SetPixel(x, y, color);
                }
            }
        } 
        texture.Apply();

        return texture;
    }

    private void SplashEventHandler(Vector3 pos, Wall wall)
    {
        Vector2 position = Vector2.zero;
        int rot = 0;

        switch (wall)
        {
            case Wall.Bottom:
                position = new Vector2(pos.z, -pos.x) / 20;
                position += new Vector2(0.75f, 0.25f);
                break;
            case Wall.Left:
                position = new Vector2(-pos.y, -pos.x) / 20;
                position += new Vector2(0.25f, 0.25f);
                rot = -1;
                break;
            case Wall.Right:
                position = new Vector2(pos.z, pos.y) / 20;
                position += new Vector2(0.75f, 0.75f);
                rot = 1;
                break;
            default:
                break;
        }
        texture = AddSplash(texture, position, rot);
    }

    Texture2D AddSplash(Texture2D main, Vector2 pos, int rotate)
    {
        int startX = (int)(pos.x * main.width) - splashTex.width / 2;
        int startY = (int)(pos.y * main.height) - splashTex.height / 2;
        Vector2 start = new Vector2Int(startX, startY);

        Texture2D rSplashTex = rotateTexture(splashTex, Random.Range(0, 360));
        for (int x = 0; x < splashTex.width; x++)
        {
            for (int y = 0; y < splashTex.height; y++)
            {

                Color bgColor = main.GetPixel((int)start.x + x, (int)start.y + y);
                Color sColor = rSplashTex.GetPixel(x, y);
                if (sColor.a != 0)
                    sColor = slimeColor;

                Color fColor = Color.Lerp(bgColor, sColor, sColor.a / 1.0f);

                main.SetPixel((int)start.x + x, (int)start.y + y, fColor);
            }
        }

        if(rotate != 0)
        {
            start = RotateV2(start, 90 * rotate);
            switch (rotate)
            {
                case 1:
                    start += new Vector2(main.width - splashTex.width, 0);
                    for (int x = 0; x < splashTex.width; x++)
                    {
                        for (int y = splashTex.height; y >= 0; y--)
                            {
                            //Debug.Log(start);
                            if ((int)start.x + x >= main.width / 2)
                                break;
                            Color bgColor = main.GetPixel((int)start.x + x, (int)start.y + y);
                            Color sColor = rSplashTex.GetPixel(x, y);
                            if (sColor.a != 0)
                                sColor = slimeColor;

                            Color fColor = Color.Lerp(bgColor, sColor, sColor.a / 1.0f);

                            main.SetPixel((int)start.x + x, (int)start.y + y, fColor);
                        }
                    }
                    break;
                case -1:
                    start += new Vector2(0, main.height - splashTex.height);
                    for (int y = splashTex.height; y >= 0; y--)
                    {
                        for (int x = splashTex.width; x >= 0; x--)
                        {
                            //Debug.Log(start);
                            if ((int)start.y + y < main.height / 2)
                                break;
                            Color bgColor = main.GetPixel((int)start.x + x, (int)start.y + y);
                            Color sColor = rSplashTex.GetPixel(x, y);
                            if (sColor.a != 0)
                                sColor = slimeColor;

                            Color fColor = Color.Lerp(bgColor, sColor, sColor.a / 1.0f);

                            main.SetPixel((int)start.x + x, (int)start.y + y, fColor);
                        }
                    }
                    break;
                default:
                    break;
            }

            //bool isBreaking = false;
            //for (int y = splashTex.height; y >= 0; y--)
            //{
            //    for (int x = splashTex.width; x >= 0; x--)
            //    {
            //        //Debug.Log(start);
            //        if ((int)start.y + y < main.height / 2)
            //            break;
            //        Color bgColor = main.GetPixel((int)start.x + x, (int)start.y + y);
            //        Color sColor = rSplashTex.GetPixel(x, y);
            //        if (sColor.a != 0)
            //            sColor = slimeColor;

            //        Color fColor = Color.Lerp(bgColor, sColor, sColor.a / 1.0f);

            //        main.SetPixel((int)start.x + x, (int)start.y + y, fColor);
            //    }
            //}
        }

        main.Apply();
        return main;
    }

    //muss richtig gemachtz werden
    private Vector2 RotateV2(Vector2 vec, float degrees)
    {
        float sin = Mathf.Sin(degrees * Mathf.Deg2Rad);
        float cos = Mathf.Cos(degrees * Mathf.Deg2Rad);

        return new Vector2((cos * vec.x) - (sin * vec.y), (sin * vec.x) - (cos * vec.y));
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

public enum Wall
{
    Bottom,
    Left,
    Right
}
