import SwiftUI

struct ForecastItemView: View {
    
    let item: ForecastItem // Дані прогнозу
    
    let neonGradientColors: [Color]

    var body: some View {
        VStack(spacing: 12) {
            
            //Час
            Text(item.timeString)
                .font(.headline.bold())
                .foregroundColor(.white.opacity(0.8))
                .shadow(color: .white.opacity(0.5), radius: 5)
            
            //Іконка Погоди
            SmartWeatherIcon(iconCode: item.weather.first?.icon, size: 70)
                .background(.white.opacity(0.3))
                .clipShape(Circle())             
            
            //Температура
            Text(item.main.temperatureString)
                .font(.system(size: 38, weight: .bold))
                .shadow(color: .white.opacity(0.5), radius: 5)
            
            //Вітер і Тиск
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
            
            //Смуга Вологості
            HumidityProgressBar(humidity: item.main.humidity, fillColor: AppColors.indicatorCyan)
            
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 40)
        .clipShape(RoundedRectangle(cornerRadius: 24))
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
