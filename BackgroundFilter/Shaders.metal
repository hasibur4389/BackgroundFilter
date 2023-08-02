//
//  Shaders.metal
//  BackgroundFilter
//
//  Created by Hasibur Rahman on 2/8/23.
//

#include <metal_stdlib>
using namespace metal;


// represents the Vertex struct
struct VertexIn {
    float3 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
  //  float2 texCoord [[ attribute(2) ]];
};

struct RasterizerData {
    float4 position [[ position ]]; // this wont be interpolated among three veritces if we declare it this way, position will return that exact position
    float4 color;
  //  float2 texCoord ;
};


vertex RasterizerData vertex_shader(const VertexIn vertexIn [[ stage_in ]]){
    
    RasterizerData rasterizerData;
    rasterizerData.position = float4(vertexIn.position, 1);
   // rasterizerData.position.x += deltaPosition;
    rasterizerData.color = float4(vertexIn.color);
  //  rasterizerData.texCoord = vertexIn.texCoord;
    
    return rasterizerData;
}

fragment float4 fragment_shader(RasterizerData rd [[ stage_in ]]){
    return rd.color;
}
