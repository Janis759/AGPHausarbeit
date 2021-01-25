Shader "Unlit/WorldSpace_Spheres"
{
    Properties
    {
        _MAX_STEPS ("Max Steps", Int) = 100
        _MAX_DIST ("Max Dist", Int) = 100
        _SURFACE_DISTANCE ("Surface Distance", Float) = 0.001
        _SHININESS("Shininess", Range(1, 100)) = 1
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
            sampler2D wallTexture;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.rayOrigin = _WorldSpaceCameraPos;
                o.hitPosition = mul(unity_ObjectToWorld, v.vertex);
                return o;
            } 
    
            float2 GetSceneDistance(float3 p)
            {
                bool found = false;
                float2 slime = float2(10, 0);
                for (int i = 0; i < 20; i++)
                {
                    if (positions[i].w == 1)
                    {        
                        slime.x = GetDistanceSphere(p, positions[i].xyz, sphereRadius)*!found + CombinedSmoothDistance(smoothness, slime.x, GetDistanceSphere(p, positions[i].xyz, sphereRadius))*found;
                        found = true;
                    }
                }


                float2 walls = float2(CombinedDistance(sdBox(p, float3(0, 0, -5.1), float3(5, 5, .1)), CombinedDistance(sdBox(p, float3(0, -5.1, 0), float3(5, .1, 5)), sdBox(p, float3(-5.1, 0, 0), float3(.1, 5, 5)))), 1);
                float2 d = slime.x < walls.x ? slime : walls;

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
                for(int i = 0; i < _MAX_STEPS; i++)
                {
                    if(distanceToOrigin > _MAX_DIST) break;
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


            float SoftShadow(float3 ro, float3 rd, float mint, float maxt, float k)
            {
                float res = 1.0;
                float ph = 1e20;
                for (float t = mint; t < maxt; )
                {
                    float h = GetSceneDistance(ro + rd * t).x;
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
                wallcolor = tex2D(wallTexture, reflected);


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

            //Quelle: https://forum.unity.com/threads/rotation-of-texture-uvs-directly-from-a-shader.150482/ (User: Farfarer)
            float2x2 rotationMatrix(float deg)
            {
                float pi = 3.1415926;
                float rad = deg * pi / 180;
                return float2x2( cos(rad), -sin(rad), sin(rad), cos(rad));
            }

            float4 texcube( sampler2D sam, in float3 p, in float3 n, in float k)
            {
                float3 m = pow( abs(n), float3(k, k, k) );
                float4 x = tex2D( sam, p.zy+.75 );
                float4 y = tex2D( sam, mul(p.xz, rotationMatrix(90)) + float2(.75, 0.25) );
                float4 z = tex2D( sam, mul(p.yx, rotationMatrix(180)) + 0.25 );
                return (x*m.x + y*m.y + z*m.z) / (m.x + m.y + m.z);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float distanceToScene;
                float objID;
                float3 rayOrigin = i.rayOrigin;
                float3 rayDirection = normalize(i.hitPosition - rayOrigin);
                float2 (distanceToScene, objID) = Raymarch(rayOrigin, rayDirection);
                fixed4 col = 0;

                if(distanceToScene < _MAX_DIST)
                {
                    float3 p = rayOrigin + rayDirection * distanceToScene;
                    float2 uv = p.xz*float2(0.03,0.07) +.25;
                    float3 objColor = objID ? texcube(wallTexture, p/20, GetNormal(p), 4.0).rgb : slimecolor;
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
