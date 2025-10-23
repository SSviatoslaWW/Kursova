// один рядок у модалці

import SwiftUI

// MARK: - Допоміжна Зовнішня Структура
struct WeatherIcon: View {
    let url: URL?
    
    var body: some View {
        //оьробляє коректно якщо if поверне nil
        Group {
            if let url = url {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().frame(width: 30, height: 30)
                    } else {
                        ProgressView().frame(width: 30, height: 30).tint(.white)
                    }
                }
            }
        }
    }
}

struct DetailedForecastRow: View {
    
    let item: ForecastItem // Об'єкт прогнозу для конкретного 3-годинного інтервалу
    
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
                .frame(width: 50, alignment: .trailing)
        }
        // MARK: - Стилізація Рядка
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
        .foregroundColor(.white)
    }
}
