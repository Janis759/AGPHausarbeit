Shader "Unlit/RaymarchingTest_Torus"
{
    Properties
    {
        _MAX_STEPS ("Max Steps", Int) = 100
        _MAX_DIST ("Max Dist", Int) = 100
        _SURFACE_DISTANCE ("Surface Distance", Float) = 0.001
        _TORUS_MIDDLE_RADIUS ("Torus middle radius", Float) = 0.5
        _THICKNESS ("thickness", Float) = 0.2
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
            float _TORUS_MIDDLE_RADIUS;
            float _THICKNESS;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.rayOrigin = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                o.hitPosition = v.vertex;
                return o;
            }

            float GetDistanceTorus(float3 center, float radius, float thickness)
            {
                float d = length(float2(length(center.xy) - radius, center.z)) - thickness;

                return d;
            }

            float Raymarch(float3 rayOrigin, float3 rayDirection)
            {
                float distanceToOrigin = 0;
                float distanceFormSurface;
                for(int i = 0; i < _MAX_STEPS; i++)
                {
                    float3 raymarchingPosition = rayOrigin + distanceToOrigin * rayDirection;
                    distanceFormSurface = GetDistanceTorus(raymarchingPosition, _TORUS_MIDDLE_RADIUS, _THICKNESS);
                    distanceToOrigin += distanceFormSurface;
                    if(distanceFormSurface < _SURFACE_DISTANCE || distanceToOrigin > _MAX_DIST) break;
                }

                return distanceToOrigin;
            }

            float3 GetNormal (float3 surfacePoint)
            {
                float2 offset = float2(.01, 0);
                float3 normal = GetDistanceTorus(surfacePoint, _TORUS_MIDDLE_RADIUS, _THICKNESS) - float3(
                    GetDistanceTorus(surfacePoint - offset.xyy, _TORUS_MIDDLE_RADIUS, _THICKNESS),
                    GetDistanceTorus(surfacePoint - offset.yxy, _TORUS_MIDDLE_RADIUS, _THICKNESS),
                    GetDistanceTorus(surfacePoint - offset.yyx, _TORUS_MIDDLE_RADIUS, _THICKNESS));
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
                //col.rg = uv;
                return col;
            }
            ENDCG
        }
    }
}
