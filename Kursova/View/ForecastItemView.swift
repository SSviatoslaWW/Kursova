// View/ForecastItemView.swift

import SwiftUI

/// Структура відображає одну компактну картку прогнозу в горизонтальному ScrollView.
/// Показує час та температуру для 3-годинного інтервалу.
struct ForecastItemView: View {
    
    // MARK: - Властивості
    
    let item: ForecastItem //Дані прогнозу для конкретного 3-годинного інтервалу
    
    /// Форматує Unix timestamp у рядок часу (наприклад, "18:00").
    var timeString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // Формат Година:Хвилина
        return formatter.string(from: date)
    }
    
    // MARK: - Body View
    
    var body: some View {
        VStack(spacing: 8) {
            
            // 1. Час
            Text(timeString) 
                .font(.caption)
            
            // 2. Іконка Погоди
            if let url = item.weather.first?.iconURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().frame(width: 40, height: 40)
                    } else {
                        ProgressView()
                            .frame(width: 40, height: 40)
                            .tint(.white)
                    }
                }
            }
            
            // 3. Температура
            Text(item.main.temperatureString)
                .font(.headline)
            
            // --- ВІТЕР ---
            if let windData = item.wind {
                HStack(spacing: 3) {
                    Image(systemName: "wind") //Іконка вітру
                        .resizable().frame(width: 11, height: 11)
                    
                    Text("\(windData.speedString) \(windData.directionShort)")
                        .font(.caption)
                        .lineLimit(1)
                }
                
                // ---ТИСК---
                HStack(spacing: 3) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .resizable().frame(width: 11, height: 11)
                    
                    Text("\(item.main.pressure) гПа")
                        .font(.caption)
                        .lineLimit(1)
                }
                
                // ---ВОЛОГІСТЬ---
                HStack(spacing: 3) {
                    Image(systemName: "drop.fill")
                        .resizable().frame(width: 12, height: 12)
                        .foregroundColor(.indigo)
                    
                    Text("\(item.main.humidity)%")
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.2))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}
