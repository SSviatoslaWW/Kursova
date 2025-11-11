// View/ForecastItemView.swift

import SwiftUI

/// Структура відображає одну картку прогнозу в стилі "неонового скла".
struct ForecastItemView: View {
    
    // MARK: - Властивості
    
    let item: ForecastItem // Дані прогнозу
    
    let neonGradientColors: [Color]
    
    /// Форматує Unix timestamp у рядок часу (наприклад, "18:00").
    var timeString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // MARK: - Body View
    
    var body: some View {
        VStack(spacing: 12) {
            
            // 1. Час
            Text(timeString)
                .font(.headline.bold())
                .foregroundColor(.white.opacity(0.8))
                .shadow(color: .white.opacity(0.5), radius: 5)
            
            // 2. Іконка Погоди
            if let url = item.weather.first?.iconURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
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
                .font(.system(size: 38, weight: .bold))
                .shadow(color: .white.opacity(0.5), radius: 5)
            
            // 4. Вітер і Тиск
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
                    Image(systemName: "barometer")
                        .font(.caption)
                    Text("\(item.main.pressure) гПа")
                        .font(.callout.weight(.medium))
                        .lineLimit(1)
                }
            }
            .foregroundColor(.white.opacity(0.8))
            
            // 5. Смуга Вологості
            HumidityProgressBar(humidity: item.main.humidity, fillColor: AppColors.indicatorCyan)
            
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 40)
        .clipShape(RoundedRectangle(cornerRadius: 24)) // Округлені кути
        .overlay( // Неонова рамка
            NeonBorder(
                shape: RoundedRectangle(cornerRadius: 24),
                colors: neonGradientColors,
                lineWidth: 3,
                blurRadius: 4
            )
        )
        .shadow(color: neonGradientColors.first?.opacity(0.3) ?? .white.opacity(0.3), radius: 10, y: 5)
    }
}
