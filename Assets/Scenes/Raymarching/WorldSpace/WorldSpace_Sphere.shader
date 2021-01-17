Shader "Unlit/WorldSpace_Spheres"
{
    Properties
    {
        _MAX_STEPS ("Max Steps", Int) = 100
        _MAX_DIST ("Max Dist", Int) = 100
        _SURFACE_DISTANCE ("Surface Distance", Float) = 0.001
        //sphereRadius ("Sphere radius", Float) = 0.5
        //smoothness ("Smoothness", Float) = 0.0
        //lightDirection("Light position", Vector) = (0, 0, 0, 0) 
        _SHININESS("Shininess", Range(1, 100)) = 1
        //slimecolor("SlimeColor", Color) = (0, 0, 0.5)
        //wallcolor("WallColor", Color) = (.8, .8, 0.8)
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

            #include "UnityCG.cginc"
            #include "Assets/CgIncludes/SDF.cginc"



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

            fixed _MAX_STEPS;
            fixed _MAX_DIST;
            float _SURFACE_DISTANCE;
            float sphereRadius;
            float smoothness;
            float3 lightDirection;
            float _SHININESS;
            float4 slimecolor;
            float4 wallcolor;
            float4 positions[20];
            float lightIntesity;
            float2 shadowDistance;
            float shadowPenumbra;
            float shadowIntencity;

            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.rayOrigin = _WorldSpaceCameraPos;
                o.hitPosition = mul(unity_ObjectToWorld, v.vertex);
                return o;
            } 
    
            float4 GetSceneDistance(float3 p)
            {
                bool found = false;
                float4 slime = float4(slimecolor.rgb, 10);
                for (int i = 0; i < 20; i++)
                {
                    if (positions[i].w == 1)
                    {        
                        slime.w = GetDistanceSphere(p, positions[i].xyz, sphereRadius)*!found + CombinedSmoothDistance(smoothness, slime.w, GetDistanceSphere(p, positions[i].xyz, sphereRadius))*found;
                        found = true;
                    }
                }

                float4 walls = float4(wallcolor.rgb, CombinedDistance(sdBox(p, float3(0, 0, -5.1), float3(5, 5, .1)), CombinedDistance(sdBox(p, float3(0, -5.1, 0), float3(5, .1, 5)), sdBox(p, float3(-5.1, 0, 0), float3(.1, 5, 5)))));
                float4 d = slime.w < walls.w ? slime : walls;

                return d;
            }

            float Raymarch(float3 rayOrigin, float3 rayDirection, inout float3 color)
            {
                float distanceToOrigin = 0;
                float distanceFormSurface;
                for(int i = 0; i < _MAX_STEPS; i++)
                {
                    if(distanceToOrigin > _MAX_DIST) break;
                    float3 raymarchingPosition = rayOrigin + distanceToOrigin * rayDirection;
                    float4 coloredSceneDistance = GetSceneDistance(raymarchingPosition);
                    distanceFormSurface = coloredSceneDistance.w;
                    distanceToOrigin += distanceFormSurface;
                    if (distanceFormSurface < _SURFACE_DISTANCE)
                    {
                        color = coloredSceneDistance.rgb;
                    }
                }

                return distanceToOrigin;
            }

            /*float3 GetNormal(float3 p) // for function f(p)
            {
                const float h = 0.01; // replace by an appropriate value
                const float2 k = float2(1, -1);
                return normalize(k.xyy * GetSceneDistance(p + k.xyy * h).w +
                    k.yyx * GetSceneDistance(p + k.yyx * h).w +
                    k.yxy * GetSceneDistance(p + k.yxy * h).w +
                    k.xxx * GetSceneDistance(p + k.xxx * h)).w;
            }*/

            float3 GetNormal (float3 surfacePoint)
            {
                float2 offset = float2(0.01, 0);
                float3 normal = GetSceneDistance(surfacePoint).w - float3(
                    GetSceneDistance(surfacePoint - offset.xyy).w,
                    GetSceneDistance(surfacePoint - offset.yxy).w,
                    GetSceneDistance(surfacePoint - offset.yyx).w);
                return normalize(normal);
            }

            float SoftShadow(float3 ro, float3 rd, float mint, float maxt, float k)
            {
                float res = 1.0;
                float ph = 1e20;
                for (float t = mint; t < maxt; )
                {
                    float h = GetSceneDistance(ro + rd * t).w;
                    if (h < 0.001)
                        return 0.0;
                    float y = h * h / (2.0 * ph);
                    float d = sqrt(h * h - y * y);
                    res = min(res, k * d / max(0.0, t - y));
                    ph = h;
                    t += h;
                }
                return res;
            }

            float3 Shading(float3 p, float3 normal)
            {
                float res = max(0, dot(-lightDirection, normal)) * lightIntesity;
                float shadow = SoftShadow(p, -lightDirection, shadowDistance.x, shadowDistance.y, shadowPenumbra) * 0.5 + 0.5;
                shadow = max(0.0, pow(shadow, shadowIntencity));
                res *= shadow;

                return res;
            }

            float3 PhongLightning(float3 position, float3 normal, float3 camPos, float3 color, float3 ro, float3 rd)
            {
                float3 reflected = reflect(-lightDirection, normal);
                float3 view = normalize(position - camPos);

                float3 ambientColor = float3(.1, .1, .1) * color;

                float dotNL = Shading(position, normal);
                float3 diffuseColor = float3(.7, .7, .7) * color * dotNL;

                float3 specularColor = float3(0, 0, 0);
                float dotRV = 0;
                if(dotNL > 0)
                {
                    dotRV = max(0, dot(reflected, view));
                    float gloss = pow(dotRV, _SHININESS);
                    specularColor = float3(.1, .1, .1) * gloss;
                    
                }

                return ambientColor + diffuseColor + specularColor;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv-.5;
                float3 rayOrigin = i.rayOrigin;
                float3 rayDirection = normalize(i.hitPosition - rayOrigin);
                float3 objColor = float3(0,0,0);
                float distanceToScene = Raymarch(rayOrigin, rayDirection, objColor);
                fixed4 col = 0;

                if(distanceToScene < _MAX_DIST)
                {
                    float3 p = rayOrigin + rayDirection * distanceToScene;
                    float3 color = PhongLightning(p, GetNormal(p), rayOrigin, objColor, rayOrigin, rayDirection);
                    col.rgb = color.rgb;
                }
                else discard;
                return col;
            }
            ENDCG
        }
    }
}
