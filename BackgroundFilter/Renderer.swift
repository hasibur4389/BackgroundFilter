//
//  Renderer.swift
//  BackgroundFilter
//
//  Created by Hasibur Rahman on 1/8/23.
//

import Foundation
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    typealias float2 = SIMD2<Float>
    typealias float3 = SIMD3<Float>
    typealias float4 = SIMD4<Float>
    
    struct Vertex {
        var position: float3
        var color: float4
       // var texture: float2
    }
    
    var parent: MainImageView
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    
    let vertices = [
         // Triangle 1
        Vertex(position: float3(-1, 1, 0), color: float4(1, 0, 0, 1)), // Top Left
        Vertex(position: float3(-1, -1, 0), color: float4(0, 1, 0, 1)), // Bottom Left
        Vertex(position: float3(1, -1, 0), color: float4(0, 0, 1, 1)), //Bottom Right
        
        // Triangle 2
        
        Vertex(position: float3(-1, 1, 0), color: float4(0, 0, 0, 1)), // Top Left
        Vertex(position: float3(1, 1, 0), color: float4(0, 1, 0, 1)), // Top Right
        Vertex(position: float3(1, -1, 0), color: float4(0, 0, 0, 1)) // Bottom Right
        

    ]
    
    
    init(_ parent: MainImageView){
        
        self.parent = parent
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        super.init()
        
        createVertexBuffer()
        
        buildPipelineState()
    }
    
    func  createVertexBuffer(){
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])
    }
    
    func buildPipelineState(){
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let vertexDescriptor = MTLVertexDescriptor()
        let library = metalDevice.makeDefaultLibrary()
        
        // Describe the Vertices , add properties for each vertex property
        // position
        vertexDescriptor.attributes[0].format = .float3  // type of data
        vertexDescriptor.attributes[0].bufferIndex = 0 // at which buffer we are allocationg this vertex
        vertexDescriptor.attributes[0].offset = 0  // is it the first offset? if not add the memories of former offsets
        // color
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<float3>.stride
        // texture
//        vertexDescriptor.attributes[2].format = .float2
//        vertexDescriptor.attributes[2].bufferIndex = 0
//        vertexDescriptor.attributes[2].offset = MemoryLayout<float3>.stride + MemoryLayout<float4>.stride
        // What type (Vertex) memory for layout 0 where our three 1st attributes are located
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertex_shader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragment_shader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        do{
            try pipelineState = metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch{
            print("\(error.localizedDescription)")
            fatalError(error.localizedDescription)

        }
    }
    
   
    
    
}

extension Renderer{
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else{
            print("Drawable error didn't get currentDrawable")
            return
        }
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0.5, blue: 0.5, alpha: 1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
