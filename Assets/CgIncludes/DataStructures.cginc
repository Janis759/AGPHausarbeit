#ifndef DATA_STRUCTURES_INCLUDED
#define DATA_STRUCTURES_INCLUDED

/*
    Data structures for data stream between application,
    vertex and fragment shader.

    Unitys library UnityCG.cginc contains other appdata variants.
*/

struct appdata {
    float4 position : POSITION;
    float3 normal : NORMAL;
    fixed4 color : COLOR;
};
   
struct v2f {
    float4 position : SV_POSITION;
    float4 color : COLOR;
};
   
struct f2fb {
	fixed4 color : SV_TARGET;
};

/*
    light weight structures for class-related data
*/

struct Material {
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
    float shininess;
};

struct Light {
    float3 toLight;
    float attenuation;
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
};

struct Camera {
    float3 position;
    float3 toCamera;
};

#endif // DATA_STRUCTURES_INCLUDED