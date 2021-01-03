Shader "Unlit/RaymarchingTest_SphereToBBox_Morph"
{
    Properties
    {
        _MAX_STEPS ("Max Steps", Int) = 100
        _MAX_DIST ("Max Dist", Int) = 100
        _SURFACE_DISTANCE ("Surface Distance", Float) = 0.001
        _TORUS_MIDDLE_RADIUS ("Torus middle radius", Float) = 0.5
        _THICKNESS ("thickness", Float) = 0.2
        _MORPH_STATE ("Morph state", Range(0, 1)) = 0
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
            fixed _MORPH_STATE;

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

            float sdBoundingBox( float3 center, float3 cornerDistance, float thickness )
            {
                center = abs(center)-cornerDistance;
                float3 q = abs(center+thickness)-thickness;
                return min(min(
                length(max(float3(center.x,q.y,q.z),0.0))+min(max(center.x,max(q.y,q.z)),0.0),
                length(max(float3(q.x,center.y,q.z),0.0))+min(max(q.x,max(center.y,q.z)),0.0)),
                length(max(float3(q.x,q.y,center.z),0.0))+min(max(q.x,max(q.y,center.z)),0.0));
            }

            float GetDistanceMorphed(float3 center, float radius, float thickness)
            {
                float d = lerp(GetDistanceSphere(center, radius), sdBoundingBox(center, radius, thickness), _MORPH_STATE);

                return d;
            }

            float Raymarch(float3 rayOrigin, float3 rayDirection)
            {
                float distanceToOrigin = 0;
                float distanceFormSurface;
                for(int i = 0; i < _MAX_STEPS; i++)
                {
                    float3 raymarchingPosition = rayOrigin + distanceToOrigin * rayDirection;
                    distanceFormSurface = GetDistanceMorphed(raymarchingPosition, _TORUS_MIDDLE_RADIUS, _THICKNESS);
                    distanceToOrigin += distanceFormSurface;
                    if(distanceFormSurface < _SURFACE_DISTANCE || distanceToOrigin > _MAX_DIST) break;
                }

                return distanceToOrigin;
            }

            float3 GetNormal (float3 surfacePoint)
            {
                float2 offset = float2(.01, 0);
                float3 normal = GetDistanceMorphed(surfacePoint, _TORUS_MIDDLE_RADIUS, _THICKNESS) - float3(
                    GetDistanceMorphed(surfacePoint - offset.xyy, _TORUS_MIDDLE_RADIUS, _THICKNESS),
                    GetDistanceMorphed(surfacePoint - offset.yxy, _TORUS_MIDDLE_RADIUS, _THICKNESS),
                    GetDistanceMorphed(surfacePoint - offset.yyx, _TORUS_MIDDLE_RADIUS, _THICKNESS));
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
                else discard;
                //col.rg = uv;
                return col;
            }
            ENDCG
        }
    }
}
