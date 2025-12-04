import SwiftUI

struct NeonBorder<S: Shape>: View {
    let shape: S
    let colors: [Color]
    let lineWidth: CGFloat
    let blurRadius: CGFloat
    
    var body: some View {
        
        // 2. Створюємо градієнт
        let gradient = AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center,
            
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
        
        ZStack {
            // Шар 1: Широке "сяйво" (haze)
            shape
                .stroke(gradient, lineWidth: lineWidth) //обведення
                .blur(radius: blurRadius)
            
            // Шар 2: Яскрава "серцевина" (hot core)
            shape
                .stroke(gradient, lineWidth: lineWidth / 2)
                .blur(radius: blurRadius / 3)
        }
    }
}
