// View/ForecastItemView.swift

import SwiftUI

struct ForecastItemView: View {
    let item: ForecastItem
    
    var timeString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(timeString).font(.caption)
            
            if let url = item.weather.first?.iconURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().frame(width: 40, height: 40)
                    } else {
                        // Зробіть ProgressView видимим
                        ProgressView().frame(width: 40, height: 40).tint(.white)
                    }
                }
            }
            
            Text(item.main.temperatureString).font(.headline)
        }
        .padding(10)
        .background(Color.white.opacity(0.2))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}
