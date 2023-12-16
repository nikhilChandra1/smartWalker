//
//  SpeedComponent.swift
//  smartWalker
//
//  Created by Nikhil Chandra on 10/31/23.
//

import SwiftUI

struct SpeedComponent: View {
    var title = "Average Speed"
    @Binding var value: String
    var body: some View {
        VStack {
            Text(title)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.red) // Adjust color to fit your app's theme
            Spacer()
            Text(value)
                .font(.system(size: 40))
                .fontWeight(.semibold)
                .foregroundColor(.primary) // Adjust color
            Spacer()
        }
        .padding()
        .frame(maxWidth:.infinity)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: .gray, radius: 10, x: 0, y: 5)
        )
    
    }
}

struct SpeedComponent_Previews: PreviewProvider {
    static var previews: some View {
        SpeedComponent( value: .constant("3.23 m/s"))
    }
}
