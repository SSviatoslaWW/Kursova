import SwiftUI

final class SearchPanelViewModel: ObservableObject {
    
    /// Виконує пошук погоди для міста (з optional координатами)
    func performSearch(
        city: String,
        lat: Double? = nil,
        lon: Double? = nil,
        weatherViewModel: WeatherViewModel
    ) {
        guard !city.isEmpty else { return }
        
        weatherViewModel.fetchWeather(city: city, lat: lat, lon: lon)
    }
    
    /// Розрахунок висоти дропдауну з результатами
    func calculateHeight(for resultsCount: Int) -> CGFloat {
        let rowHeight: CGFloat = 65
        let contentHeight = CGFloat(resultsCount) * rowHeight
        return min(contentHeight, 190)
    }
}
