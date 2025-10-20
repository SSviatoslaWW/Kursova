// View/ForecastItemView.swift

import SwiftUI

/// Структура відображає одну компактну картку прогнозу в горизонтальному ScrollView.
/// Показує час та температуру для 3-годинного інтервалу.
struct ForecastItemView: View {
    
    // MARK: - Властивості
    
    let item: ForecastItem // ➡️ Дані прогнозу для конкретного 3-годинного інтервалу
    
    // MARK: - Обчислювані Властивості
    
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
            Text(timeString) // ⬅️ Відображення часу
                .font(.caption)
            
            // 2. Іконка Погоди
            if let url = item.weather.first?.iconURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        // ➡️ Успіх: Відображаємо іконку з API
                        image.resizable().frame(width: 40, height: 40)
                    } else {
                        // ➡️ Заглушка: Відображаємо індикатор завантаження
                        ProgressView()
                            .frame(width: 40, height: 40)
                            .tint(.white) // Білий колір для контрасту на темному тлі
                    }
                }
            }
            
            // 3. Температура
            Text(item.main.temperatureString) // ⬅️ Відображення температури (°C)
                .font(.headline)
            
        }
        // MARK: - Стилізація Картки
        .padding(10) // Внутрішній відступ для вмісту
        .background(Color.white.opacity(0.2)) // Напівпрозорий білий фон
        .foregroundColor(.white) // Колір тексту білий
        .cornerRadius(10) // Заокруглення кутів
    }
}
