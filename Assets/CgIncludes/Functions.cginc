#ifndef FUNCTIONS_INCLUDED
#define FUNCTIONS_INCLUDED

/*
    This library aims at encapsulate the access to
    Unitys global variables.  Unity ShaderLab / Cg illumination shader 
    should have almost the same structure as their counterparts in GLSL. 
*

/*
    UnityLightingCommon.cginc defines
     _LightColor0
*/

#include "UnityLightingCommon.cginc"

/*
    Light Setup:
    The quality of ambient light is defined in the lighting settings,
    where users can choose between coloring by skyboxes or a specific color. 

    Unity incorporates several different build-in rendering pipeline.
        Forward (default), Deferred
    The graphic quality settings define, which render pipeline is active.
    The Forward renderer is split up into several rendering passes, where the lights
    are ordered according to their impact / importance:
    The ForwardBase pass always employs a directional light.
    Up to 4 additional light can be considered in ForwardAdd passes.
    
    In a pass with tag { "LightMode" = "ForwardBase" } these globals 
    contain the direction and color of a directional light.
    float4 _WorldSpaceLightPos0 
    fixed4 _LightColor0 

    For more information on light setups in the forward renderer see:
    https://en.wikibooks.org/wiki/Cg_Programming/Unity/Diffuse_Reflection
*/

float3 GetAmbientLightColor() {
    return UNITY_LIGHTMODEL_AMBIENT.rgb;
}

float3 GetDiffuseLightColor() {
    return _LightColor0.rgb;
}

float3 GetSpecularLightColor() {
    return _LightColor0.rgb;
}

// constant, linear and quadratic factors of attenuation
float3 _lightFallOff = float3( 1.0, 0.1, 0.01);

float getAttenuation( float3 lightDir ) {
    float dist = length ( lightDir );
    float constWeight = _lightFallOff.x;
    float linearWeight = _lightFallOff.y;
    float quadraticWeight = _lightFallOff.z;
    float factors = constWeight +
					linearWeight * dist +
					quadraticWeight * dist * dist;
    return 1.0 / factors;
}

/*
     Unity uses the homogenous component to differ between points and directions
    v.w == 0.0 :  v = (v_x, v_y, v_z) is a direction
    v.w == 1.0 :  v = (v_x, v_y, v_z) is a point

    Unitys library UnityCG.cginc contains the similiar function
        float3 UnityWorldSpaceLightDir( float3 worldPosition )
    without normalizing the return vector.
*/

inline bool isDirectionalLight() {
    return _WorldSpaceLightPos0.w == 0.0;
}

float3 GetToLightDirection( float4 positionObjectSpace ) {
    float4 toLight;

    if (isDirectionalLight()) {
        // no light position but light direction
        toLight = _WorldSpaceLightPos0;
    } else {
        float4 position = mul( unity_ObjectToWorld, positionObjectSpace );
        toLight = _WorldSpaceLightPos0 - position;
    }
    
    return normalize( toLight.xyz );
}

/*
    Camera Setup:
    float3 _WorldSpaceCameraPos

    Unitys library UnityCG.cginc contains the similiar functions
        float3 WorldSpaceViewDir( float3 objectPosition )
        float3 UnityWorldSpaceViewDir( float3 worldPosition )
    without normalizing the return vector.
*/

float3 GetToCameraDirection( float4 positionObjectSpace ) {
    float4 position = mul( unity_ObjectToWorld, positionObjectSpace );
    float3 toCamera = _WorldSpaceCameraPos - position.xyz;
    return normalize( toCamera );
}

/*
    Transform matrices for object / model to world transformation
    for points and normals (special directions).

    float4x4 unity_WorldToObject
    float4x4 unity_WorldToObject: inverse transformation

    model to world transformation with matrix M for points v:  
         v' = M v

    model to world transformation of normals:  
         n' = (M^{-1})^T n
         n' = n^T M^{-1}
    M^{-1} is the inverse of matrix M  

    Unitys library UnityCG.cginc contains a similiar function:
        UnityObjectToWorldNormal

    For a detailled discussion, WHY normals need other 
    transforms than point see:
    http://www.songho.ca/opengl/gl_normaltransform.html
    https://www.lighthouse3d.com/tutorials/glsl-12-tutorial/the-normal-matrix/
*/

float3 GetObjectToWorld ( float3 v ) {
    float3x3 modelMatrix = (float3x3) unity_ObjectToWorld;
    return normalize( mul( modelMatrix, v ));
}

float4 GetObjectToWorld ( float4 v ) {
    float4x4 modelMatrix = unity_ObjectToWorld;
    return normalize( mul( modelMatrix, v ));
}

float3 GetObjectToWorldNormal ( float3 normal) {
    float3x3 modelMatrixInverse = (float3x3) unity_WorldToObject;
    return normalize( mul( normal, modelMatrixInverse ));
}

#endif // FUNCTIONS_INCLUDED