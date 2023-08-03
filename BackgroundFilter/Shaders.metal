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

//fragment half4 fragment_shader(RasterizerData rd [[ stage_in ]], texture2d<float> texture_bg [[ texture(0) ]], texture2d<float> texture_img [[ texture(1) ]]){
//
//    constexpr sampler defaultSampler;
//    float2 coord = rd.texCoord * 2.0;
////    float p = coord.x * 0.5 + 0.5;
////    float q = coord.y * 0.5 + 0.5;
//    float4 mycolor;
//    float4 bgcolor = texture_bg.sample(defaultSampler, rd.texCoord);
//    //Mark: Gotta change the texcoord as its not mapped with the image because the texCoord is the middle position
//    float4 imgcolor = texture_img.sample(defaultSampler, coord);
//
////
//    if(rd.texCoord.x >= (-0.65 + 1.0)/2.0 && rd.texCoord.x <= (0.65 + 1.0)/2.0 && rd.texCoord.y >= 1 - (0.65 + 1) / 2.0 && rd.texCoord.y <= 0.825){
//        return half4(imgcolor.r, imgcolor.g, imgcolor.b, imgcolor.a);
//        }
//        else {
//            return half4(bgcolor.r, bgcolor.g, bgcolor.b, bgcolor.a);
//        }
//
////    if (rd.position.x >= -0.65 && rd.position.x <= 0.65 && rd.position.y <= 0.65 && rd.position.y >= 0.0) {
////        return half4(imgcolor.r, imgcolor.g, imgcolor.b, imgcolor.a);
////    } else {
////        return half4(bgcolor.r, bgcolor.g, bgcolor.b, bgcolor.a);
////    }
////
//  //  return half4(imgcolor.r, imgcolor.g, imgcolor.b, imgcolor.a);
//
//}


/*
 
 1. (-1, 1) say (x, y) coordinate to texture cooridnate (0, 1) say (p, q)
      p = (x+1)/2, q = 1 - (y+1)/2 first transformation
 
 2. now in GPU screen everything is [0 to 1] and bgImage is textureing based on that but the actual image needed to texture inside the bg image, when we pass the same texture coordinate for both of them the corner of the inside image lets represnt (0.175, 0.175) texture coordinate now the images (0.175, 0.175) is mapped to this but i need images 0,0 to map to this (0.175, 0.175) and continueing that and the formula for that is :
     
     ConvertedImageTextureCoordinate.x = (rd.texCoord.x - regionMin.x) / (regionMax.x - regionMin.x)
     here, rd.texCoord is the main screen or bg texture coordinate , regionMin and Max is the converted (-1, 1) space to (0, 1) coordinate space
 
        
 
 3. Subtracting regionMin from rd.texCoord: rd.texCoord represents the original texture coordinate of the pixel in consideration, which ranges from 0 to 1 in both X and Y directions. The regionMin is the minimum X and Y coordinates of the defined region, also normalized between 0 and 1. When we subtract regionMin.x from rd.texCoord.x, we are effectively translating the X-coordinate of rd.texCoord to be relative to the origin of the defined region. This operation ensures that if rd.texCoord is equal to regionMin, the resulting imgTexCoord.x becomes 0. Similarly, when we subtract regionMin.y from rd.texCoord.y, we are translating the Y-coordinate of rd.texCoord to be relative to the origin of the defined region. This ensures that if rd.texCoord is equal to regionMin, the resulting imgTexCoord.y becomes 0.
 
 4. Dividing by the range (regionMax - regionMin): After the translation step, the transformed X and Y coordinates are still in the range [0, regionMax.x - regionMin.x] for X and [0, regionMax.y - regionMin.y] for Y. To normalize these transformed coordinates and scale them to the range [0, 1], we divide them by the range (regionMax - regionMin). So, when we divide imgTexCoord.x by (regionMax.x - regionMin.x), we ensure that if rd.texCoord is equal to regionMax, the resulting imgTexCoord.x becomes 1. Similarly, when we divide imgTexCoord.y by (regionMax.y - regionMin.y), we ensure that if rd.texCoord is equal to regionMax, the resulting imgTexCoord.y becomes 1.
 */



fragment float4 fragment_shader(RasterizerData rd [[ stage_in ]],
                               texture2d<float> texture_bg [[ texture(0) ]],
                               texture2d<float> texture_img [[ texture(1) ]]) {
    constexpr sampler defaultSampler;

//    float2 coord = rd.texCoord;
    float4 myTextureColor; // we will return this color
   float2 imgTexCoord;

    // Define the region in normalized texture coordinates (0 to 1)
//    float2 regionMin = float2((-0.65 + 1.0) / 2.0, 1.0 - (0.65 + 1.0) / 2.0);
//    float2 regionMax = float2((0.65 + 1.0) / 2.0, 1.0 - ( 0.0 + 1.0) / 2.0);
    float2 regionMin = float2(0.2, 0.2);
    float2 regionMax = float2(0.8, 0.8);

    // Check if the current texCoord is inside the specified region
    bool isInsideRegion = (rd.texCoord.x >= regionMin.x && rd.texCoord.x <= regionMax.x &&
                           rd.texCoord.y >= regionMin.y && rd.texCoord.y <= regionMax.y);

    // Calculate the scaled and shifted texCoord for the image
   
    imgTexCoord.x = (rd.texCoord.x - regionMin.x) / (regionMax.x - regionMin.x);
    imgTexCoord.y = (rd.texCoord.y - regionMin.y) / (regionMax.y - regionMin.y);
    
    // Calculate the center of the texture
//    float2 center = float2(0.5, 0.5);
//
//    // Calculate the scaled and shifted texture coordinates for the background
//    float2 bgTexCoord = center - imgTexCoord;

    // Sample the image using the transformed texCoord if inside the region, else use original texCoord
    
    if (isInsideRegion) {
        myTextureColor = texture_img.sample(defaultSampler, imgTexCoord);
    } else {
        myTextureColor = texture_bg.sample(defaultSampler, rd.texCoord);
    }

    //return float4(0,1,0,1);
    return myTextureColor;
}
