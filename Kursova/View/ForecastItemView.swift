// View/ForecastItemView.swift

import SwiftUI

/// Створює кастомну смугу прогресу для вологості з неоновим заповненням
struct HumidityProgressBar: View {
    let humidity: Int // Значення вологості, наприклад 77
    
    // ✅ ЗМІНЕНО: Тепер приймає один колір для заповнення
    let fillColor: Color
        
    var body: some View {
        let humidityFraction = Double(humidity) / 100.0
        
        VStack(spacing: 4) { // Використовуємо VStack, щоб розмістити текст під смугою
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 1. "Доріжка" (фон смуги)
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    // 2. ✅ ОНОВЛЕНО: Просте неонове заповнення
                    Capsule()
                        .fill(fillColor) // Використовуємо один колір
                        // Додаємо тінь для "неонового" ефекту
                        .shadow(color: fillColor.opacity(0.7), radius: 3, x: 0, y: 0)
                        // Обрізаємо заповнення по ширині
                        .frame(width: geometry.size.width * humidityFraction)
                        //.clipped() // Обрізаємо, щоб тінь не виходила за межі доріжки
                }
            }
            .frame(height: 8) // Встановлюємо висоту для GeometryReader
            
            // 3. Текстова мітка під смугою (без змін)
            Text("\(humidity)%")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .white.opacity(0.4), radius: 2) // Легке сяйво
        }
    }
}




/// Структура відображає одну картку прогнозу в стилі "неонового скла".
struct ForecastItemView: View {
    
    // MARK: - Властивості
    
    let item: ForecastItem // Дані прогнозу
    // ✅ Змінено: Тепер приймає масив кольорів для градієнту рамки
    let neonGradientColors: [Color]
    
    /// Форматує Unix timestamp у рядок часу (наприклад, "18:00").
    var timeString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // Формат Година:Хвилина
        return formatter.string(from: date)
    }
    
    // MARK: - Body View
    
    var body: some View {
        VStack(spacing: 12) {
            
            // 1. Час
            Text(timeString)
                .font(.headline.bold())
                .foregroundColor(.white.opacity(0.8))
                .shadow(color: .white.opacity(0.5), radius: 5) // Неоновий ефект
            
            // 2. Іконка Погоди
            if let url = item.weather.first?.iconURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70) // Збільшена іконка
                            .background(.white.opacity(0.3))
                            .clipShape(Circle())
                    } else {
                        ProgressView()
                            .frame(width: 70, height: 70)
                            .tint(.white)
                    }
                }
            } else {
                // Заглушка на випадок, якщо URL немає
                Image(systemName: "icloud.slash")
                    .frame(width: 70, height: 70)
            }
            
            // 3. Температура
            Text(item.main.temperatureString)
                .font(.system(size: 38, weight: .bold)) // Великий шрифт
                .shadow(color: .white.opacity(0.5), radius: 5) // Неоновий ефект
            
            // 4. Вітер і Тиск (в одному рядку)
            VStack {
                // Вітер
                if let windData = item.wind {
                    HStack(spacing: 4) {
                        Image(systemName: "wind")
                            .font(.caption)
                        Text(windData.speedString + " " + windData.directionShort) 
                            .font(.callout.weight(.medium))
                    }
                }
                
                Spacer()
                
                // Тиск
                HStack(spacing: 4) {
                    Image(systemName: "barometer") // Більш релевантна іконка
                        .font(.caption)
                    Text("\(item.main.pressure) гПа")
                        .font(.callout.weight(.medium))
                        .lineLimit(1)
                }
            }
            .foregroundColor(.white.opacity(0.8))
            
            // 5. Смуга Вологості (використовуємо нашу нову View)
            // ✅ Передаємо кольори для градієнта заповнення
            HumidityProgressBar(humidity: item.main.humidity, fillColor: .cyan)
            
            // ❗️ Якщо у вас є дані по хмарності, ви можете додати другу смугу:
            // if let cloudiness = item.clouds?.all {
            //    HumidityProgressBar(humidity: cloudiness, gradientColors: neonGradientColors)
            // }
            
        }
        .padding(.vertical, 16)
        
        // ✅✅✅ --- ОСЬ ЗМІНА --- ✅✅✅
        // Збільшуємо відступи зліва і справа, щоб картка стала ширшою
        .padding(.horizontal, 40)
        
        //.background(.ultraThinMaterial) // Ефект "матового скла"
        .clipShape(RoundedRectangle(cornerRadius: 24)) // Округлені кути
        .overlay( // Неонова рамка
            AnimatedNeonBorder( // Використовуємо нашу анімовану рамку
                shape: RoundedRectangle(cornerRadius: 24),
                // ✅ Використовуємо передані кольори для градієнта рамки
                colors: neonGradientColors,
                lineWidth: 3,
                blurRadius: 4
            )
        )
        // ✅ Використовуємо перший колір градієнта для тіні
        .shadow(color: neonGradientColors.first?.opacity(0.3) ?? .white.opacity(0.3), radius: 10, y: 5)
    }
}
