import SwiftUI

struct NeonBorder<S: Shape>: View {
    let shape: S
    let colors: [Color]
    let lineWidth: CGFloat
    let blurRadius: CGFloat
    
    var body: some View {
        
        let gradient = AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center,
            
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
        
        ZStack {
            shape
                .stroke(gradient, lineWidth: lineWidth) //обведення
                .blur(radius: blurRadius)
            
            shape
                .stroke(gradient, lineWidth: lineWidth / 2)
                .blur(radius: blurRadius / 3)
        }
    }
}
