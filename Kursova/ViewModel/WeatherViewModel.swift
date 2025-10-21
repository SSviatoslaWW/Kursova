// ViewModel/WeatherViewModel.swift

import SwiftUI
import Foundation
import CoreLocation

class WeatherViewModel: NSObject, ObservableObject {

    // MARK: - Constants & Published Properties
    private let DEFAULT_CITY = "Lviv"
    
    @Published var currentCity: String
    @Published var currentWeather: CurrentWeatherResponse?
    @Published var forecastItems: [ForecastItem] = []
    @Published var dailyForecast: [ForecastItem] = []
    @Published var groupedDailyForecast: [Date: [ForecastItem]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = WeatherService()
    public var locationManager: LocationManager
    
    private var isInitialLoad = true
    private var isUserSearch = false
    
    override init() {
        self.currentCity = DEFAULT_CITY
        self.locationManager = LocationManager()
        super.init()
    }
    
    // MARK: - Public Methods
    
    func requestUserLocation() {
        // Запобігаємо повторному запиту, якщо погода вже завантажена
        guard isInitialLoad else { return }
        
        locationManager.requestLocation { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let coordinate):
                    // Тепер цей виклик працюватиме коректно
                    self.fetchWeather(city: nil, lat: coordinate.latitude, lon: coordinate.longitude)
                    
                case .failure:
                    if self.isInitialLoad {
                        self.fetchWeather(city: self.DEFAULT_CITY, lat: nil, lon: nil)
                    }
                }
            }
        }
    }
    
    // ❗️ 1. Перетворено lazy var на звичайний метод `func`. Це виправляє помилки.
    func fetchWeather(city: String?, lat: Double?, lon: Double?) {
        // ❗️ 2. Оскільки це метод, [weak self] та guard let self більше не потрібні всередині
        self.isUserSearch = (city != self.DEFAULT_CITY && city != nil && lat == nil && lon == nil)
        
        self.isLoading = true
        self.errorMessage = nil
        
        if let lat = lat, let lon = lon {
            self.fetchWeatherAndForecast(lat: lat, lon: lon)
        } else if let city = city, !city.isEmpty {
            self.currentCity = city
            let isReserve = (city == self.DEFAULT_CITY)
            self.fetchWeatherAndForecast(city: city, isSystemReserve: isReserve)
        }
    }

    func getBackgroundGradient() -> [Color] {
        guard let weatherData = currentWeather else {
            return [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.3, green: 0.3, blue: 0.4)]
        }
        let mainCondition = weatherData.weather.first?.main ?? "Default"
        let temp = weatherData.main.temp
        
        switch mainCondition {
        case "Thunderstorm": return [Color(red: 0.3, green: 0.1, blue: 0.4), Color(red: 0.1, green: 0.1, blue: 0.15)]
        case "Snow": return [Color(red: 0.6, green: 0.7, blue: 0.9), Color(red: 0.85, green: 0.9, blue: 0.95)]
        case "Rain", "Drizzle": return [Color(red: 0.3, green: 0.4, blue: 0.6), Color(red: 0.4, green: 0.5, blue: 0.7)]
        default: break
        }
        
        if temp >= 30 {
            return [Color(red: 0.9, green: 0.5, blue: 0.1), Color(red: 1.0, green: 0.8, blue: 0.4)]
        } else if temp >= 15 {
            return [Color(red: 0.2, green: 0.6, blue: 0.85), Color(red: 0.6, green: 0.8, blue: 1.0)]
        } else if temp >= 5 {
            return [Color(red: 0.4, green: 0.5, blue: 0.6), Color(red: 0.7, green: 0.75, blue: 0.8)]
        } else {
            return [Color(red: 0.2, green: 0.2, blue: 0.5), Color(red: 0.4, green: 0.4, blue: 0.7)]
        }
    }
    
    // MARK: - Private Fetching Methods
    
    private func fetchWeatherAndForecast(lat: Double, lon: Double) {
        service.fetchCurrentWeather(lat: lat, lon: lon) { [weak self] currentResult in
            self?.handleFetchResults(currentResult: currentResult, isLocationAttempt: true, isSystemReserve: false, lat: lat, lon: lon, city: nil)
        }
    }
    
    private func fetchWeatherAndForecast(city: String, isSystemReserve: Bool) {
        service.fetchCurrentWeather(city: city) { [weak self] currentResult in
            self?.handleFetchResults(currentResult: currentResult, isLocationAttempt: false, isSystemReserve: isSystemReserve, lat: nil, lon: nil, city: city)
        }
    }

    private func handleFetchResults(currentResult: Result<CurrentWeatherResponse, APIError>, isLocationAttempt: Bool, isSystemReserve: Bool, lat: Double?, lon: Double?, city: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch currentResult {
            case .success(let response):
                self.currentWeather = response
                self.currentCity = response.name
                self.isInitialLoad = false
                self.fetchForecast(city: self.currentCity, lat: response.coord.lat, lon: response.coord.lon)
                
            case .failure(let error):
                if error == .cityNotFound && self.isUserSearch {
                    self.errorMessage = "Місто не знайдено. Перевірте назву."
                    self.currentWeather = nil
                    self.isLoading = false
                } else if !isSystemReserve {
                    self.currentCity = self.DEFAULT_CITY
                    self.fetchWeatherAndForecast(city: self.DEFAULT_CITY, isSystemReserve: true)
                } else {
                    self.errorMessage = "Критична помилка мережі. Не вдалося завантажити дані."
                    self.isLoading = false
                }
            }
        }
    }
    
    private func fetchForecast(city: String?, lat: Double?, lon: Double?) {
        if let lat = lat, let lon = lon {
            service.fetchForecast(lat: lat, lon: lon) { [weak self] forecastResult in
                self?.handleForecastResult(forecastResult)
            }
        } else if let city = city {
            service.fetchForecast(city: city) { [weak self] forecastResult in
                self?.handleForecastResult(forecastResult)
            }
        }
    }
    
    private func handleForecastResult(_ result: Result<ForecastResponse, APIError>) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.forecastItems = Array(response.list.prefix(8))
                self.dailyForecast = self.filterDailyForecast(response.list)
                self.groupedDailyForecast = self.groupForecastByDay(response.list)
            case .failure(let error):
                self.errorMessage = self.errorMessage ?? error.localizedDescription
            }
        }
    }
    
    private func filterDailyForecast(_ list: [ForecastItem]) -> [ForecastItem] {
        var filteredItems: [ForecastItem] = []
        var seenDates: Set<String> = []
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        for item in list {
            let date = item.date
            let dateString = dateFormatter.string(from: date)
            if !calendar.isDateInToday(date) && !seenDates.contains(dateString) {
                filteredItems.append(item)
                seenDates.insert(dateString)
            }
            if filteredItems.count >= 5 { break }
        }
        return filteredItems
    }
    
    private func groupForecastByDay(_ list: [ForecastItem]) -> [Date: [ForecastItem]] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: list) { item in
            calendar.startOfDay(for: item.date)
        }
        return grouped
    }
}
