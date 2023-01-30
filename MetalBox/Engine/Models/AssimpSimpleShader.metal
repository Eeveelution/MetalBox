//
//  AssimpMeshSimpleShader.metal
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 23.01.23.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 textureCoordinate [[attribute(2)]];
} VertexInput;

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} VertexOutput;

typedef struct {
    half4 color [[color(0)]];
} FragmentOut;

vertex VertexOutput assimpSimpleVertexShader(VertexInput input [[stage_in]]) {
    VertexOutput out;
    
    out.position = float4(input.position, 1);
    out.textureCoordinate = input.textureCoordinate;
    
    return out;
}

fragment FragmentOut assimpSimpleFragmentShader(VertexOutput input [[stage_in]],
                                                    texture2d<half> texture [[texture(0)]]
) {
    FragmentOut out;
    
    out.color = half4(input.position.z, 0, 0, 1.0);
    
    return out;
    
    constexpr sampler textureSampler(min_filter::linear, mag_filter::linear);
    
    out.color = texture.sample(textureSampler, input.textureCoordinate);
    
    return out;
}
