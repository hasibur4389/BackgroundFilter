//
//  ContentView.swift
//  BackgroundFilter
//
//  Created by Hasibur Rahman on 1/8/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack{ // Set the alignment to .leading (or .top) to align the MainImageView at the top
            MainImageView().frame(height: 500, alignment: .topTrailing)
                   Spacer() // Use Spacer to push the MainImageView to the top
            ZStack{
                Text("Hello")
            }
               }
             
           
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
