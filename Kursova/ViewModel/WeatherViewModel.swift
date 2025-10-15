// ViewModel/WeatherViewModel.swift

import SwiftUI
import Foundation

class WeatherViewModel: ObservableObject {
    
    @Published var currentWeather: CurrentWeatherResponse?
    @Published var forecastItems: [ForecastItem] = []
    @Published var dailyForecast: [ForecastItem] = [] // 🛑 НОВЕ: Для 5-денного прогнозу
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentCity: String = "Lviv"
    
    private let service = WeatherService()
    
    // MARK: - Логіка Градієнту
    func getBackgroundGradient() -> [Color] {
        guard let mainCondition = currentWeather?.weather.first?.main else {
            // Темний градієнт за замовчуванням
            return [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.3, green: 0.3, blue: 0.4)]
        }
        
        switch mainCondition {
        case "Clear":
            return [Color(red: 0.3, green: 0.7, blue: 0.9), Color(red: 0.9, green: 0.6, blue: 0.2)]
        case "Clouds":
            return [Color(red: 0.4, green: 0.5, blue: 0.6), Color(red: 0.7, green: 0.7, blue: 0.7)]
        case "Rain", "Drizzle":
            return [Color(red: 0.2, green: 0.3, blue: 0.5), Color(red: 0.1, green: 0.2, blue: 0.3)]
        case "Thunderstorm":
            return [Color(red: 0.1, green: 0.0, blue: 0.2), Color(red: 0.3, green: 0.2, blue: 0.4)]
        case "Snow":
            return [Color(red: 0.7, green: 0.8, blue: 1.0), Color(red: 0.4, green: 0.5, blue: 0.7)]
        case "Mist", "Smoke", "Haze", "Fog":
            return [Color(red: 0.7, green: 0.7, blue: 0.7), Color(red: 0.8, green: 0.8, blue: 0.9)]
        default:
            return [Color(red: 0.5, green: 0.5, blue: 0.5), Color(red: 0.8, green: 0.8, blue: 0.8)]
        }
    }
    
    // MARK: - Мережева Логіка
    
    lazy var fetchWeather: (String) -> Void = { [weak self] cityName in
        guard let self = self else { return }
        
        self.isLoading = true
        self.errorMessage = nil
        self.currentCity = cityName
        
        self.service.fetchCurrentWeather(city: cityName) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.currentWeather = response
                    self.fetchForecast(cityName)
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    private func fetchForecast(_ cityName: String) {
        service.fetchForecast(city: cityName) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.forecastItems = Array(response.list.prefix(8))
                    self.dailyForecast = self.filterDailyForecast(response.list) // 🛑 Фільтруємо 5 днів
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // 🛑 НОВА ЛОГІКА: Фільтрація для 5 Днів
    private func filterDailyForecast(_ list: [ForecastItem]) -> [ForecastItem] {
        var filteredItems: [ForecastItem] = []
        var seenDates: Set<String> = []
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for item in list {
            let date = item.date
            let dateString = dateFormatter.string(from: date)
            
            // Якщо це не сьогодні і ми ще не бачили цю дату
            if !calendar.isDateInToday(date) && !seenDates.contains(dateString) {
                
                // Додаємо перший запис за день (для огляду)
                filteredItems.append(item)
                seenDates.insert(dateString)
            }
            
            if filteredItems.count >= 5 {
                break
            }
        }
        return filteredItems
    }
    
    private func handleError(_ error: APIError) {
        self.isLoading = false
        self.currentWeather = nil
        self.forecastItems = []
        self.dailyForecast = []
        self.errorMessage = error.localizedDescription
    }
}
