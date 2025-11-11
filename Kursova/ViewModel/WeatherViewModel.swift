// ViewModel/WeatherViewModel.swift

import SwiftUI
import Foundation
import CoreLocation

class WeatherViewModel: NSObject, ObservableObject {
    
    private let DEFAULT_CITY = "Lviv"
    
    @Published var currentCity: String
    @Published var currentWeather: CurrentWeatherResponse? //Поточна погода
    @Published var forecastItems: [ForecastItem] = [] //Погода на найбличі годин
    @Published var dailyForecast: [ForecastItem] = [] //Прогноз на 5 днів для кнопок
    @Published var groupedDailyForecast: [Date: [ForecastItem]] = [:] //детальний прогноз по дням для модалки
    @Published var isLoading = false // перевірка чи йде завантаження
    @Published var errorMessage: String? //текст помилки для відображеня
    
    private let service = WeatherService()
    public var locationManager: LocationManager
    
    private var isInitialLoad = true //перевірка чи перший запуск додатку
    private var isUserSearch = false // перевірка чи користувач ввів місто
    
    override init() {
        self.currentCity = DEFAULT_CITY
        self.locationManager = LocationManager()
        super.init()
    }
    
    //пошук користувацьої локації
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
    
    // пошук погоди за координатами та містом
    func fetchWeather(city: String?, lat: Double?, lon: Double?) {
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
    static func getBackground(for mainCondition: String?) -> String {
        guard let condition = mainCondition else {
            return "ErrorBG"
        }
        
        switch condition {
        case "Thunderstorm": return "ThunderstormBG"
        case "Snow": return "SnowBG"
        case "Rain", "Drizzle": return "RainBG"
        default: return "GoodWeatherBG"
        }
    }
    
    
    //Викликається коли є відомі координати
    private func fetchWeatherAndForecast(lat: Double, lon: Double) {
        service.fetchCurrentWeather(lat: lat, lon: lon) { [weak self] currentResult in
            self?.handleFetchResults(currentResult: currentResult, isLocationAttempt: true, isSystemReserve: false, lat: lat, lon: lon, city: nil)
        }
    }
    
    //викликається коли  відоме місто
    private func fetchWeatherAndForecast(city: String, isSystemReserve: Bool) {
        service.fetchCurrentWeather(city: city) { [weak self] currentResult in
            self?.handleFetchResults(currentResult: currentResult, isLocationAttempt: false, isSystemReserve: isSystemReserve, lat: nil, lon: nil, city: city)
        }
    }
    
    
    //обробка даних отриманих від API для поточної погоди
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
    
    // відповідає за прогнозування погоди на 5 деів
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
    
    //Обробляє прогноз на кілька днів
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
        var seenDates: Set<String> = [] //збереження дат які ми вже додали
        let calendar = Calendar.current //календар для роботи з датами
        let dateFormatter = DateFormatter() //перетворення дати в рядок
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
    
    //групує детальний прогноз погоди для модалки
    private func groupForecastByDay(_ list: [ForecastItem]) -> [Date: [ForecastItem]] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: list) { item in
            calendar.startOfDay(for: item.date)
        }
        return grouped
    }
    
    
    
    func forceRefreshUserLocation() {
        isLoading = true
        errorMessage = nil
        
        // Спробуємо використати "свіжу" кешовану локацію (наприклад, < 5 хвилин)
        if let lastLocation = locationManager.manager.location,
           Date().timeIntervalSince(lastLocation.timestamp) < 300 {
            print("🚀 Знайдено свіжу кешовану локацію, використовуємо її.")
            self.fetchWeather(city: nil, lat: lastLocation.coordinate.latitude, lon: lastLocation.coordinate.longitude)
            return
        }
        // Додаємо таймаут на випадок зависання (опціонально, але рекомендовано)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            if self?.isLoading == true {
                print("⚠️ Таймаут геолокації.")
                self?.isLoading = false
                self?.errorMessage = "Не вдалося швидко визначити місцезнаходження."
            }
        }
        
        locationManager.requestLocation { [weak self] result in
            guard let self = self else { return }
            // Якщо таймаут вже спрацював і вимкнув isLoading, ігноруємо пізній результат
            guard self.isLoading else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let coordinate):
                    print("📍 Нову геолокацію отримано.")
                    self.fetchWeather(city: nil, lat: coordinate.latitude, lon: coordinate.longitude)
                case .failure(let error):
                    print("❌ Помилка: \(error)")
                    self.errorMessage = "Помилка визначення місцезнаходження."
                    self.isLoading = false
                }
            }
        }
    }
}
