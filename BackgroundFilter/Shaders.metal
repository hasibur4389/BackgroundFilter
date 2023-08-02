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
    float2 texCoord [[ attribute(2) ]];
};

struct RasterizerData {
    float4 position [[ position ]]; // this wont be interpolated among three veritces if we declare it this way, position will return that exact position
    float4 color;
    float2 texCoord ;
};


vertex RasterizerData vertex_shader(const VertexIn vertexIn [[ stage_in ]]){
    
    RasterizerData rasterizerData;
    rasterizerData.position = float4(vertexIn.position, 1);
   // rasterizerData.position.x += deltaPosition;
    rasterizerData.color = float4(vertexIn.color);
    rasterizerData.texCoord = vertexIn.texCoord;
    
    return rasterizerData;
}

fragment half4 fragment_shader(RasterizerData rd [[ stage_in ]], texture2d<float> texture_bg [[ texture(0) ]], texture2d<float> texture_img [[ texture(1) ]]){
    
    constexpr sampler defaultSampler;
    float2 coord = rd.texCoord;
//    float p = coord.x * 0.5 + 0.5;
//    float q = coord.y * 0.5 + 0.5;
    float4 mycolor;
    float4 bgcolor = texture_bg.sample(defaultSampler, rd.texCoord);
    //Mark: Gotta change the texcoord as its not mapped with the image because the texCoord is the middle position
    float4 imgcolor = texture_img.sample(defaultSampler, rd.texCoord);
    
//
    if(rd.texCoord.x >= (-0.65 + 1.0)/2.0 && rd.texCoord.x <= (0.65 + 1.0)/2.0 && rd.texCoord.y >= 1 - (0.65 + 1) / 2.0 && rd.texCoord.y <= 0.825){
        return half4(imgcolor.r, imgcolor.g, imgcolor.b, imgcolor.a);
        }
        else {
            return half4(bgcolor.r, bgcolor.g, bgcolor.b, bgcolor.a);
        }
    
//    if (rd.position.x >= -0.65 && rd.position.x <= 0.65 && rd.position.y <= 0.65 && rd.position.y >= 0.0) {
//        return half4(imgcolor.r, imgcolor.g, imgcolor.b, imgcolor.a);
//    } else {
//        return half4(bgcolor.r, bgcolor.g, bgcolor.b, bgcolor.a);
//    }
//
  //  return half4(imgcolor.r, imgcolor.g, imgcolor.b, imgcolor.a);
    
}


