//
//  DefferedShaders.metal
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 20.01.23.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    
} VertexInput;

typedef struct {
    float4 position [[position]];
    float3 normal;
    float2 textureCoordinates;
} PixelIn;

vertex PixelIn geometryPassVertexShader(VertexInput input [[stage_in]]) {
    PixelIn out;
    
    out.position = float4(1, 1, 1, 0);
    
    return out;
}

typedef struct {
    half4 position [[color(0)]];
    half4 normal [[color(1)]];
    half4 colorSpecular [[color(2)]];
} PixelOut;

fragment PixelOut geometryPassPixelShader(PixelIn input [[stage_in]],
                                          texture2d<half> diffuse [[texture(0)]],
                                          texture2d<half> specular [[texture(1)]] ) {
    PixelOut out;
    
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    float3 normalizedNormal = normalize(input.normal);
    
    out.position = half4(input.position);
    out.normal = half4(normalizedNormal.x, normalizedNormal.y, normalizedNormal.z, 1);
    
    half4 colorSample = diffuse.sample(textureSampler, input.textureCoordinates);
    half4 specularSample = specular.sample(textureSampler, input.textureCoordinates);
    
    out.colorSpecular.rgb = colorSample.rgb;
    out.colorSpecular.a = colorSample.a;
    
    return out;
}

//Lighting Pass
