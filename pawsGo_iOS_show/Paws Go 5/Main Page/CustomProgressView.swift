//
//  CustomProgressView.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2023-01-01.
//

import SwiftUI

struct CustomProgressView: View {
    
    @Binding var showProgress: Bool
    
    var body: some View {
        VStack {
            ProgressView("Processing...")
                //.background(RoundedRectangle(cornerRadius: 50.0)
                //.fill(Color.white)
                //.overlay(RoundedRectangle(cornerRadius: 50.0)
                 //           .stroke(Color(red: 0.7725, green: 0.9412, blue: 0.8157), style: StrokeStyle())))
                .progressViewStyle(CircularProgressViewStyle(tint: Color.green))
                .padding()
                .accentColor(Color.green)
                //.frame(width: 100, height: 100, alignment: .center)
                .font(.system(size: 5))
                .scaleEffect(4)
                //.scaleEffect(x: 1, y: 4, anchor: .center)
                //.scale
                
        }
        .isHidden(!self.showProgress)
        
    }
}
/*
 struct CustomProgressView_Previews: PreviewProvider {
 
 
 static var previews: some View {
 CustomProgressView()
 }
 }
 */
