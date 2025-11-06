import SwiftUI

/// Створює ЯСКРАВУ неонову рамку з кольорами, що "біжать" по колу.
struct AnimatedNeonBorder<S: Shape>: View {
    let shape: S
    let colors: [Color]
    let lineWidth: CGFloat
    let blurRadius: CGFloat
    
    // 1. Стан для відстеження кута градієнта
    @State private var gradientStartAngle: Double = 0
    
    var body: some View {
        
        // 2. Створюємо градієнт, чиї кути будуть анімовані
        let gradient = AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center,
            // 👇 Ми анімуємо ці значення
            startAngle: .degrees(gradientStartAngle),
            endAngle: .degrees(gradientStartAngle + 360)
        )
        
        ZStack {
            // Шар 1: Широке "сяйво" (haze)
            shape
                .stroke(gradient, lineWidth: lineWidth)
                .blur(radius: blurRadius)
            
            // Шар 2: Яскрава "серцевина" (hot core)
            shape
                .stroke(gradient, lineWidth: lineWidth / 2)
                .blur(radius: blurRadius / 3)
        }
        
        
        // 4. Запускаємо анімацію для нашого стану
        .onAppear {
            withAnimation(
                .linear(duration: 4) // 4 секунди на повний оберт
                    .repeatForever(autoreverses: false)
            ) {
                // Ми анімуємо саме змінну стану, а не View
                gradientStartAngle = 360
            }
        }
    }
}
