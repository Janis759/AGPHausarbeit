// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/WorldSpace_Spheres"
{
    Properties
    {
        _MAX_STEPS ("Max Steps", Int) = 100
        _MAX_DIST ("Max Dist", Int) = 100
        _SURFACE_DISTANCE ("Surface Distance", Float) = 0.001
        _SPHERE_RADIUS ("Sphere radius", Float) = 0.5
        _CENTER1 ("Sphere 1 Center", Vector) = (0, 0, 0)
        _CENTER2 ("Sphere 2 Center", Vector) = (0, 0, 0)
        _SMOOTHNESS ("Smoothness", Float) = 0.0
        _LIGHT_POSITION("Light position", Vector) = (0, 0, 0) 
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

            float3 positions[10];

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
            float _SPHERE_RADIUS;
            float3 _CENTER1;
            float3 _CENTER2;
            float _SMOOTHNESS;
            float3 _LIGHT_POSITION;
            float _SHININESS;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.rayOrigin = _WorldSpaceCameraPos;
                o.hitPosition = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float GetDistanceSphere(float3 p, float3 center, float radius)
            {
                float d = length(p + center) - radius;

                return d;
            }

            float CombinedDistance(float3 p, float d1, float d2)
            {
                float d = min(d1, d2);
                return d;
            }

            float CombinedSmoothDistance(float3 p, float k, float d1, float d2) 
            {
                float h = clamp(0.5 + 0.5*(d1-d2)/k, 0.0, 1.0);
                return lerp(d1, d2, h ) - k*h*(1.0-h); 
            }

            float GetSceneDistance(float3 p)
            {
                float3 toll = positions[0];
                float d = CombinedSmoothDistance (p, _SMOOTHNESS, GetDistanceSphere(p, toll, _SPHERE_RADIUS), GetDistanceSphere(p, positions[1], _SPHERE_RADIUS));
                d = CombinedDistance (p, d, GetDistanceSphere(p, -_LIGHT_POSITION, 0.1));

                return d;
            }

            float Raymarch(float3 rayOrigin, float3 rayDirection)
            {
                float distanceToOrigin = 0;
                float distanceFormSurface;
                for(int i = 0; i < _MAX_STEPS; i++)
                {
                    float3 raymarchingPosition = rayOrigin + distanceToOrigin * rayDirection;
                    distanceFormSurface = GetSceneDistance(raymarchingPosition);
                    distanceToOrigin += distanceFormSurface;
                    if(distanceFormSurface < _SURFACE_DISTANCE || distanceToOrigin > _MAX_DIST) break;
                }

                return distanceToOrigin;
            }

            float3 GetNormal (float3 surfacePoint)
            {
                float2 offset = float2(0.01, 0);
                float3 normal = GetSceneDistance(surfacePoint) - float3(
                    GetSceneDistance(surfacePoint - offset.xyy),
                    GetSceneDistance(surfacePoint - offset.yxy),
                    GetSceneDistance(surfacePoint - offset.yyx));
                return normalize(normal);
            }

            float3 PhongLightning(float3 position, float3 normal, float3 camPos)
            {
                float3 light = normalize(_LIGHT_POSITION - position);
                float3 reflected = reflect(light, normal);
                float3 view = normalize(position - camPos);

                float3 ambientColor = float3(.1, .1, .1) * float3(0, 0, .1);

                float dotNL = max(0, dot(light, normal));
                float3 diffuseColor = float3(.7, .7, .7) * float3(0, 0, .75) * dotNL;

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

                float distanceToScene = Raymarch(rayOrigin, rayDirection);
                fixed4 col = 0;

                if(distanceToScene < _MAX_DIST)
                {
                    float3 p = rayOrigin + rayDirection * distanceToScene;
                    float3 color = PhongLightning(p, GetNormal(p), rayOrigin);
                    col.rgb = color;
                }
                else discard;
                return col;
            }
            ENDCG
        }
    }
}
