//
//  PressureComponent.swift
//  smartWalker
//
//  Created by Nikhil Chandra on 10/31/23.
//

import SwiftUI

struct PressureComponent: View {
    @Binding var leftPressure: String
    @Binding var rightPressure: String
    
    var body: some View {
        VStack {
                    Text("Pressure")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.red) // Adjust color to fit your app's theme
                    
                    HStack {
                        Spacer()
                        VStack() {
                            Text("Left")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.gray) // Adjust color
                            Spacer()
                            Text(leftPressure)
                                .font(.system(size: 40))
                                .fontWeight(.semibold)
                                .foregroundColor(.primary) // Adjust color
                            Spacer()
                        }
                        Spacer()
                        Divider()
                            .background(Color.gray) // Adjust color
                        Spacer()
                        VStack() {
                            Text("Right")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.gray) // Adjust color
                            Spacer()
                            Text(rightPressure)
                                .font(.system(size: 40))
                                .fontWeight(.semibold)
                                .foregroundColor(.primary) // Adjust color
                            Spacer()
                        }
                        Spacer()
                    }
                }
        .padding()
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: .gray, radius: 10, x: 0, y: 5)
            
        )
    }
}

struct PressureComponent_Previews: PreviewProvider {
    static var previews: some View {
        PressureComponent(leftPressure: .constant("0.0 N"), rightPressure: .constant("0.0 N"))
    }
}
