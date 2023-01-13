//
//  TriangleShaders.metal
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 12.01.23.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float3 position [[attribute(0)]];
    half4 color     [[attribute(1)]];
} TriangleInputs;

typedef struct {
    float4 position [[position]];
    half4 color;
} VertexOutputs;

vertex VertexOutputs triangleVertexShader(TriangleInputs inputs [[stage_in]]) {
    VertexOutputs out;
    
    out.position = float4(inputs.position, 1.0);
    out.color = inputs.color;
    
    return out;
}

fragment float4 trianglePixelShader(VertexOutputs inputs [[stage_in]]) {
    return float4(inputs.color);
}
