import SwiftUI

/// Створює кастомну смугу прогресу для вологості з неоновим заповненням
struct HumidityProgressBar: View {
    let humidity: Int 
    let fillColor: Color
        
    var body: some View {
        let humidityFraction = Double(humidity) / 100.0
        
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 1. "Доріжка" (фон смуги)
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    // 2. Просте неонове заповнення
                    Capsule()
                        .fill(fillColor)
                        .shadow(color: fillColor.opacity(0.7), radius: 3, x: 0, y: 0)
                        .frame(width: geometry.size.width * humidityFraction)
                }
            }
            .frame(height: 8)
            
            Text("\(humidity)%")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .white.opacity(0.4), radius: 2)
        }
    }
}
