Shader "Unlit/RaymarchingTest_Sphere"
{
    Properties
    {
        _MAX_STEPS ("Max Steps", Int) = 100
        _MAX_DIST ("Max Dist", Int) = 100
        _SURFACE_DISTANCE ("Surface Distance", Float) = 0.001
        _SPHERE_RADIUS ("Sphere radius", Float) = 0.5
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.rayOrigin = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                o.hitPosition = v.vertex;
                return o;
            }

            float GetDistanceSphere(float3 center, float radius)
            {
                float d = length(center) - radius;

                return d;
            }

            float Raymarch(float3 rayOrigin, float3 rayDirection)
            {
                float distanceToOrigin = 0;
                float distanceFormSurface;
                for(int i = 0; i < _MAX_STEPS; i++)
                {
                    float3 raymarchingPosition = rayOrigin + distanceToOrigin * rayDirection;
                    distanceFormSurface = GetDistanceSphere(raymarchingPosition, _SPHERE_RADIUS);
                    distanceToOrigin += distanceFormSurface;
                    if(distanceFormSurface < _SURFACE_DISTANCE || distanceToOrigin > _MAX_DIST) break;
                }

                return distanceToOrigin;
            }

            float3 GetNormal (float3 surfacePoint)
            {
                float2 offset = float2(0.01, 0);
                float3 normal = GetDistanceSphere(surfacePoint, _SPHERE_RADIUS) - float3(
                    GetDistanceSphere(surfacePoint - offset.xyy, _SPHERE_RADIUS),
                    GetDistanceSphere(surfacePoint - offset.yxy, _SPHERE_RADIUS),
                    GetDistanceSphere(surfacePoint - offset.yyx, _SPHERE_RADIUS));
                return normalize(normal);
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
                    float3 normals = GetNormal(p);
                    col.rgb = normals;
                }
                return col;
            }
            ENDCG
        }
    }
}
