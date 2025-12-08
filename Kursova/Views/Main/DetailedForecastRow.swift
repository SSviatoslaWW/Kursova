import SwiftUI

struct DetailedForecastRow: View {
    
    let item: ForecastItem
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: item.date)
    }

    var body: some View {
        HStack (spacing: 0) {
            //Час та Температура
            VStack(alignment: .leading, spacing: 4) {
                Text(timeString)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(item.main.temperatureString)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            //Іконка та Опис
            HStack(spacing: 12) {
                SmartWeatherIcon(iconCode: item.weather.first?.icon, size: 60)
                    .id(item.weather.first?.icon)
                Text(item.weather.first?.description.capitalized ?? "---")
                    .font(.body)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.4))
                
                NeonBorder(
                    shape: RoundedRectangle(cornerRadius: 20),
                    colors: AppColors.oceanCool,
                    lineWidth: 3,
                    blurRadius: 6
                )
            }
        )
        .padding(2)
    }
}
