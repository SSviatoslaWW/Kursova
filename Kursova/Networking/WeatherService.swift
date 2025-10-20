// Networking/WeatherService.swift

import Foundation

class WeatherService {
    
    // ⚠️ ПРИМІТКА: Потрібні файли Constants.swift та APIError.swift
    
    // MARK: - Core Fetch Method
    
    /// Універсальна функція для виконання мережевих запитів та декодування JSON.
    private func fetchData<T: Decodable>(endpoint: String, queryItems: [URLQueryItem], completion: @escaping (Result<T, APIError>) -> Void) {
        
        // 1. Створення компонента URL
        var components = URLComponents(string: Constants.baseURL + endpoint)
        
        // 2. 🔑 Базові параметри, необхідні для кожного запиту
        var baseQueryItems = [
            URLQueryItem(name: "appid", value: Constants.apiKey),     // 🔑 API ключ
            URLQueryItem(name: "units", value: Constants.units),      // 🌡️ Метричні одиниці (°C)
            URLQueryItem(name: "lang", value: "uk")                   // 🌐 Мова відповіді (Українська)
        ]
        
        // 3. Додаємо специфічні параметри (координати або назву міста)
        baseQueryItems.append(contentsOf: queryItems)
        components?.queryItems = baseQueryItems
        
        // 4. Валідація URL
        guard let url = components?.url else {
            completion(.failure(.invalidURL)) // Помилка: Недійсний URL
            return
        }
        
        // 5. Запуск мережевого завдання
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            // 6. Обробка мережевої помилки
            if let error = error {
                completion(.failure(.other(error.localizedDescription)))
                return
            }
            
            // 7. Обробка HTTP статус-кодів
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                if statusCode == 404 {
                    completion(.failure(.cityNotFound)) // 🛑 Помилка: Місто не знайдено
                    return
                } else if statusCode != 200 {
                    completion(.failure(.other("HTTP Error: \(statusCode)"))) // Обробка інших HTTP помилок.
                    return
                }
            }
            
            // 8. Перевірка наявності даних
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // 9. Декодування JSON
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data) // Спроба перетворити JSON на структуру T.
                
                // ДІАГНОСТИКА УСПІХУ (Виводиться у консоль)
                print("✅ DECODE SUCCESS: Successfully decoded object of type \(T.self)")
                
                completion(.success(decodedObject)) // Успіх
            } catch let decodeError {
                
                // ДІАГНОСТИКА ПОМИЛКИ ДЕКОДУВАННЯ
                print("❌ DECODE FAILURE: Decoding failed for type \(T.self)!")
                print("JSONDecoder Error: \(decodeError)")
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("--- RECEIVED RAW JSON (for \(T.self)): ---")
                    print(jsonString.prefix(500) + "...")
                    print("--------------------------------------------------")
                }
                
                completion(.failure(.decodingError))
            }
            
        }.resume() // Запускає мережевий запит.
    }
    
    // =============================================================
    // MARK: - Public API Endpoints (Запит за Назвою Міста)
    // =============================================================
    
    /// Запитує поточну погоду за назвою міста.
    func fetchCurrentWeather(city: String, completion: @escaping (Result<CurrentWeatherResponse, APIError>) -> Void) {
        let cityNameQuery = [URLQueryItem(name: "q", value: city)] // Параметр: ?q=city
        fetchData(endpoint: "weather", queryItems: cityNameQuery, completion: completion)
    }
    
    /// Запитує прогноз на 5 днів за назвою міста.
    func fetchForecast(city: String, completion: @escaping (Result<ForecastResponse, APIError>) -> Void) {
        let cityNameQuery = [URLQueryItem(name: "q", value: city)] // Параметр: ?q=city
        fetchData(endpoint: "forecast", queryItems: cityNameQuery, completion: completion)
    }
    
    // =============================================================
    // MARK: - Public API Endpoints (Запит за Координатами)
    // =============================================================
    
    // 💡 Приватна функція для формування запиту координат
    private func createCoordinateQuery(lat: Double, lon: Double) -> [URLQueryItem] {
        return [
            URLQueryItem(name: "lat", value: "\(lat)"), // Параметр широти
            URLQueryItem(name: "lon", value: "\(lon)")  // Параметр довготи
        ]
    }
    
    /// Запитує поточну погоду за географічними координатами.
    func fetchCurrentWeather(lat: Double, lon: Double, completion: @escaping (Result<CurrentWeatherResponse, APIError>) -> Void) {
        let query = createCoordinateQuery(lat: lat, lon: lon)
        fetchData(endpoint: "weather", queryItems: query, completion: completion)
    }
    
    /// Запитує прогноз на 5 днів за географічними координатами.
    func fetchForecast(lat: Double, lon: Double, completion: @escaping (Result<ForecastResponse, APIError>) -> Void) {
        let query = createCoordinateQuery(lat: lat, lon: lon)
        fetchData(endpoint: "forecast", queryItems: query, completion: completion)
    }
}
