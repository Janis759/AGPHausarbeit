#ifndef LIGHTING_INCLUDED
#define LIGHTING_INCLUDED

/*
    
*/

float3 PhongLighting(float3 normal, Material material, Light light, Camera camera) {
    float3 reflectedLight = reflect( -light.toLight, normal );
        
    float3 ambientColor = material.ambientColor * light.ambientColor;
   
    float  dotNL = max(0.0, dot( normal, light.toLight ));
    float3 diffuseColor = material.diffuseColor * light.diffuseColor * dotNL;
   
    float3 specularColor = float3( 0.0, 0.0, 0.0 );            
    if(dotNL > 0.0) {
        float dotRV = max( 0.0, dot( reflectedLight, camera.toCamera )) ;
        float gloss = pow( dotRV, material.shininess);
        specularColor =  material.specularColor * light.specularColor * gloss;
}
               
    float3 color = ambientColor;
    if (isDirectionalLight()) {
        // directional lights have an infinite distance
        color += diffuseColor + specularColor;
    } else {
        color += light.attenuation * (diffuseColor + specularColor);
    }

    return color;
}

#endif // LIGHTING_INCLUDED