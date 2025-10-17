// DetailedForecastRow.swift

import SwiftUI

struct DetailedForecastRow: View {
    let item: ForecastItem
    
    // Форматування часу
    var timeString: String {
        let formatter = DateFormatter()
        // Встановлюємо українську локаль для форматування часу (наприклад, 18:00)
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: item.date)
    }

    var body: some View {
        HStack(spacing: 15) { // ⬅️ Додаємо невеликий spacing
            
            // 1. Час
            Text(timeString)
                .frame(width: 50, alignment: .leading) // ⬅️ Зменшено width для компактності
                .bold()
            
            // 2. Іконка
            if let url = item.weather.first?.iconURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().frame(width: 30, height: 30)
                    } else {
                        ProgressView().frame(width: 30, height: 30).tint(.white)
                    }
                }
            }
            
            // 3. Опис (розтягується)
            Text(item.weather.first?.description.capitalized ?? "---")
                .frame(maxWidth: .infinity, alignment: .leading) // ⬅️ Розтягується
            
            // 4. Температура
            Text(item.main.temperatureString)
                .font(.body)
                .bold()
                .frame(width: 40, alignment: .trailing) // ⬅️ Зменшено width
        }
        .padding()
        .background(Color.black.opacity(0.3)) // Темний напівпрозорий фон для ряду
        .cornerRadius(10)
    }
}
