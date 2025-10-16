// ViewModel/WeatherViewModel.swift

import SwiftUI
import Foundation
import CoreLocation

class WeatherViewModel: NSObject, ObservableObject, LocationManagerDelegate {

    // MARK: - Constants & Published Properties
    private let DEFAULT_CITY = "Lviv"
    
    @Published var currentCity: String
    @Published var currentWeather: CurrentWeatherResponse?
    @Published var forecastItems: [ForecastItem] = []
    @Published var dailyForecast: [ForecastItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = WeatherService()
    public var locationManager: LocationManager
    
    private var isInitialLoad = true // 🛑 НОВИЙ ПРАПОР: Для контролю першого запуску
    private var isUserSearch = false // Для розрізнення пошуку користувача
    
    override init() {
        self.currentCity = DEFAULT_CITY
        self.locationManager = LocationManager()
        super.init()
        self.locationManager.delegate = self
        
        // 🛑 Виклик LocationManager.requestLocation() перенесено у View/WeatherDetailView.swift onAppear
    }
    
    // MARK: - Градієнт (без змін)
    func getBackgroundGradient() -> [Color] {
        guard let mainCondition = currentWeather?.weather.first?.main else {
            return [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.3, green: 0.3, blue: 0.4)]
        }
        switch mainCondition {
        case "Clear": return [Color(red: 0.3, green: 0.7, blue: 0.9), Color(red: 0.9, green: 0.6, blue: 0.2)]
        case "Clouds": return [Color(red: 0.4, green: 0.5, blue: 0.6), Color(red: 0.7, green: 0.7, blue: 0.7)]
        case "Rain", "Drizzle": return [Color(red: 0.2, green: 0.3, blue: 0.5), Color(red: 0.1, green: 0.2, blue: 0.3)]
        case "Thunderstorm": return [Color(red: 0.1, green: 0.0, blue: 0.2), Color(red: 0.3, green: 0.2, blue: 0.4)]
        case "Snow": return [Color(red: 0.7, green: 0.8, blue: 1.0), Color(red: 0.4, green: 0.5, blue: 0.7)]
        case "Mist", "Smoke", "Haze", "Fog": return [Color(red: 0.7, green: 0.7, blue: 0.7), Color(red: 0.8, green: 0.8, blue: 0.9)]
        default: return [Color(red: 0.5, green: 0.5, blue: 0.5), Color(red: 0.8, green: 0.8, blue: 0.8)]
        }
    }
    
    // MARK: - ОСНОВНИЙ ВИКЛИК ПОГОДИ
    lazy var fetchWeather: (_ city: String?, _ lat: Double?, _ lon: Double?) -> Void = { [weak self] city, lat, lon in
        guard let self = self else { return }
        
        // 🛑 ВСТАНОВЛЕННЯ ПРАПОРІВ
        self.isUserSearch = (city != self.DEFAULT_CITY && city != nil && lat == nil && lon == nil)
        
        self.isLoading = true
        self.errorMessage = nil
        
        if let lat = lat, let lon = lon {
            // Запит за координатами
            self.fetchWeatherAndForecast(lat: lat, lon: lon, isInitialLoad: self.isInitialLoad)
        } else if let city = city, !city.isEmpty {
            self.currentCity = city
            // Запит за містом
            self.fetchWeatherAndForecast(city: city, isInitialLoad: self.isInitialLoad)
        }
    }
    
    // MARK: - ПРИВАТНІ МЕТОДИ ЗАВАНТАЖЕННЯ
    
    private func fetchWeatherAndForecast(lat: Double, lon: Double, isInitialLoad: Bool) {
        service.fetchCurrentWeather(lat: lat, lon: lon) { [weak self] currentResult in
            self?.handleFetchResults(currentResult: currentResult, isLocationAttempt: true)
        }
    }
    
    private func fetchWeatherAndForecast(city: String, isInitialLoad: Bool) {
        service.fetchCurrentWeather(city: city) { [weak self] currentResult in
            self?.handleFetchResults(currentResult: currentResult, isLocationAttempt: false)
        }
    }

    private func handleFetchResults(currentResult: Result<CurrentWeatherResponse, APIError>, isLocationAttempt: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isInitialLoad = false // Після першої спроби прапор знімаємо
            
            switch currentResult {
            case .success(let response):
                self.currentWeather = response
                self.currentCity = response.name
                // Отримуємо прогноз або за координатами, або за назвою
                let cityToFetch = isLocationAttempt ? nil : response.name
                self.fetchForecast(city: cityToFetch, lat: response.coord.lat, lon: response.coord.lon)
                
            case .failure(let error):
                
                // 🛑 1. ОБРОБКА НЕЗНАЙДЕНОГО МІСТА ПІСЛЯ РУЧНОГО ПОШУКУ
                if error == .cityNotFound && self.isUserSearch {
                    self.errorMessage = "Місто не знайдено. Перевірте назву."
                    self.currentWeather = nil
                    self.isLoading = false
                    
                // 🛑 2. ОБРОБКА ПОМИЛКИ ПРИ ПОЧАТКОВОМУ ЗАВАНТАЖЕННІ (резерв Львів)
                } else if self.isInitialLoad {
                    self.currentCity = self.DEFAULT_CITY
                    self.fetchWeatherAndForecast(city: self.DEFAULT_CITY, isInitialLoad: false) // Спроба завантажити Львів
                    
                // 3. Інші помилки (проблеми з мережею, декодуванням)
                } else {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    // ... (fetchForecast та handleForecastResult - залишаємо без змін)
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

    // MARK: - LocationManagerDelegate (Обробка від LocationManager)
    
    // 🛑 ВИКЛИКАЄТЬСЯ: Якщо координати отримано успішно
    func didUpdateLocation(lat: Double, lon: Double) {
        // Успіх: викликаємо пошук погоди за координатами
        self.fetchWeather(nil, lat, lon) // CityName = nil, оскільки використовуємо координати
    }
    
    // 🛑 ВИКЛИКАЄТЬСЯ: Якщо користувач відмовив або сталася помилка
    func didFailWithError() {
        // Помилка/Відмова: якщо це був перший запуск, переходимо до Львова
        if self.isInitialLoad {
            self.fetchWeather(self.DEFAULT_CITY, nil, nil)
        }
    }
}
