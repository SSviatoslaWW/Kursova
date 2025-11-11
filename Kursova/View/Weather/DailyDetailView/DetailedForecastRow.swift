// один рядок у модалці

import SwiftUI

// MARK: - Основний Рядок Прогнозу
struct DetailedForecastRow: View {
    
    let item: ForecastItem
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: item.date)
    }

    var body: some View {
        HStack {
            // ЛІВА ЧАСТИНА: Час та Температура
            VStack(alignment: .leading, spacing: 4) {
                Text(timeString)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(item.main.temperatureString)
                    .font(.system(size: 28, weight: .bold)) // Збільшений шрифт як на макеті
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // ПРАВА ЧАСТИНА: Іконка та Опис
            HStack(spacing: 12) {
                Spacer()
                Spacer()
                Spacer()
                WeatherIcon(url: item.weather.first?.iconURL)
                Text(item.weather.first?.description.capitalized ?? "---")
                    .font(.body)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Напівпрозорий чорний фон плашки
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.4))
                
                // Неонова рамка поверх фону
                NeonBorder(
                    shape: RoundedRectangle(cornerRadius: 20),
                    colors: [.cyan, .blue, .purple, .cyan], // Можна змінити кольори тут
                    lineWidth: 3,
                    blurRadius: 6
                )
            }
        )
        // Додатковий відступ зовні, щоб рамку не обрізало
        .padding(2)
    }
}
