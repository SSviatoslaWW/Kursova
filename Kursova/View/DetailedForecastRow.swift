// DetailedForecastRow.swift

import SwiftUI

// MARK: - Допоміжна Зовнішня Структура

/// Відображає іконку погоди, завантажуючи її асинхронно з API.
struct WeatherIcon: View {
    let url: URL?
    
    var body: some View {
        Group {
            if let url = url {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().frame(width: 30, height: 30) // Фіксований розмір
                    } else {
                        ProgressView().frame(width: 30, height: 30).tint(.white) // Заглушка
                    }
                }
            }
        }
    }
}

// MARK: - Detailed Forecast Row View

/// Відображає один рядок погодинного прогнозу всередині модального вікна DailyDetailView.
struct DetailedForecastRow: View {
    
    // MARK: - Властивості
    
    let item: ForecastItem // Об'єкт прогнозу для конкретного 3-годинного інтервалу
    
    // MARK: - Обчислювані Властивості
    
    /// Форматує Unix timestamp у рядок часу (наприклад, "18:00").
    var timeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: item.date)
    }

    // MARK: - Body View
    
    var body: some View {
        HStack(spacing: 15) {
            
            // 1. Час
            Text(timeString)
                .frame(width: 50, alignment: .leading)
                .bold()
            
            // 2. Іконка (Викликаємо зовнішню структуру)
            WeatherIcon(url: item.weather.first?.iconURL)
            
            // 3. Опис Погоди
            Text(item.weather.first?.description.capitalized ?? "---")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 4. Температура
            Text(item.main.temperatureString)
                .font(.body)
                .bold()
                .frame(width: 50, alignment: .trailing) // ⬅️ Уточнено width
        }
        // MARK: - Стилізація Рядка
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
        .foregroundColor(.white)
    }
}
