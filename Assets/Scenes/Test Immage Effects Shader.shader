Shader "Custom/Test Immage Effects Shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                //col.rgb = 1 - col.rgb;
                float radius = 0.3;

                float distance = sqrt(pow((i.uv.x - 0.5)/9*10, 2) + pow((i.uv.y - 0.5)/16*10, 2));

                float grayScale = 0.2126 * col.r + 0.7152 * col.g + 0.0722 * col.b;
                
                if (distance < radius)
                {
                    float colorFactor = clamp(pow((distance / radius) , 2), 0, 1);
                    float grayFactor = 1 - colorFactor;
                    col.r = col.r * colorFactor + grayScale * grayFactor;
                    col.g = col.g * colorFactor + grayScale * grayFactor;
                    col.b = col.b * colorFactor + grayScale * grayFactor;
                }
                else
                {
                    //col = grayScale;
                }
                

                return col;
            }
            ENDCG
        }
    }
}
