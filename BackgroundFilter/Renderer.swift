//
//  Renderer.swift
//  BackgroundFilter
//
//  Created by Hasibur Rahman on 1/8/23.
//

import Foundation
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
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
        Vertex(position: [-1, -1], color: [1, 0, 0, 1]),
        Vertex(position: [1, -1], color: [0, 1, 0, 1]),
        Vertex(position: [0, 1], color: [0, 0, 1, 1])

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
        let library = metalDevice.makeDefaultLibrary()
        
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertex_shader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragment_shader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
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
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
