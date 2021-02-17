Shader "Unlit/3D-Demo"
{
    Properties
    {
        _MAX_STEPS("Max Steps", Int) = 100
        _MAX_DIST("Max Dist", Int) = 100
        _SURFACE_DISTANCE("Surface Distance", Float) = 0.001
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
                float3 rayOrigin : TEXCOORD1;
                float3 hitPosition : TEXCOORD2;
            };

            float3 goalPos;
            fixed _MAX_STEPS;
            fixed _MAX_DIST;
            float _SURFACE_DISTANCE;
            float3 lightDirection;


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.rayOrigin = _WorldSpaceCameraPos;
                o.hitPosition = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float sdCapsule(float3 p, float3 a, float3 b, float r)
            {
                float3 pa = p - a, ba = b - a;
                float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                return length(pa - ba * h) - r;
            }

            float GetSceneDistance(float3 p)
            {
                float d = sdCapsule(p, float3(0, 0, 0), float3(2, 0, 0), 0.3);

                return d;
            }

            float3 GetNormal(float3 surfacePoint)
            {
                float2 offset = float2(0.01, 0);
                float3 normal = GetSceneDistance(surfacePoint).x - float3(
                    GetSceneDistance(surfacePoint - offset.xyy).x,
                    GetSceneDistance(surfacePoint - offset.yxy).x,
                    GetSceneDistance(surfacePoint - offset.yyx).x);
                return normalize(normal);
            }

            float2 Raymarch(float3 rayOrigin, float3 rayDirection)
            {
                float distanceToOrigin = 0;
                float distanceFormSurface;
                float2 sceneDistance;
                for (int i = 0; i < _MAX_STEPS; i++)
                {
                    if (distanceToOrigin > _MAX_DIST) break;
                    float3 raymarchingPosition = rayOrigin + distanceToOrigin * rayDirection;
                    sceneDistance = GetSceneDistance(raymarchingPosition);
                    distanceFormSurface = sceneDistance.x;
                    distanceToOrigin += distanceFormSurface;
                    if (distanceFormSurface < _SURFACE_DISTANCE)
                    {
                        break;
                    }
                }

                return float2(distanceToOrigin, sceneDistance.y);
            }

            float3 PhongLightning(float3 position, float3 normal, float3 camPos, float3 color, float3 ro, float3 rd)
            {
                float3 reflected = reflect(-lightDirection, normal);
                float3 view = normalize(position - camPos);


                float3 ambientColor = float3(.3, .3, .3) * color;

                float dotNL = max(0, dot(normal, lightDirection));
                float3 diffuseColor = float3(.7, .7, .7) * color * dotNL;

                float3 specularColor = float3(0, 0, 0);
                float dotRV = 0;

                return ambientColor + diffuseColor;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 rayOrigin = i.rayOrigin;
                float3 rayDirection = normalize(i.hitPosition - rayOrigin);
                float distanceToScene = Raymarch(rayOrigin, rayDirection);
                fixed4 col = 0;

                if (distanceToScene < _MAX_DIST)
                {
                    float3 p = rayOrigin + rayDirection * distanceToScene;
                    float3 color = PhongLightning(p, GetNormal(p), rayOrigin, float3(1,1,1), rayOrigin, rayDirection);
                    col.rgb = color.rgb;
                }
                else discard;
                return col;
            }
            ENDCG
        }
    }
}
