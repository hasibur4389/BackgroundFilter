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
        mtkView.enableSetNeedsDisplay = false
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
    
        
        mtkView.framebufferOnly = true
        //mtkView.drawableSize = mtkView.frame.size
        
        // Set the desired fixed size for the MTKView
//              let fixedWidth: CGFloat = 800
             // let fixedHeight: CGFloat = 700
       // mtkView.autoResizeDrawable = false
       // mtkView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
     
             
//        mtkView.drawableSize = CGSize(width: 300, height: fixedHeight)
        
        mtkView.drawableSize = mtkView.frame.size
//        mtkView.drawableSize = CGSize(width: 400, height: 400)
        
        
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
