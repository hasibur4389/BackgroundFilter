//
//  MainImageView.swift
//  BackgroundFilter
//
//  Created by Hasibur Rahman on 1/8/23.
//

import SwiftUI
import MetalKit

struct MainImageView: UIViewRepresentable {
    
    
    
    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MainImageView>) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<MainImageView>) {
        
    }

}

struct MainImageView_Previews: PreviewProvider {
    static var previews: some View {
        MainImageView()
    }
}
