// Networking/WeatherService.swift

import Foundation

class WeatherService {
    
    // ⚠️ ПРИМІТКА: Потрібні файли Constants.swift та APIError.swift
    
    private func fetchData<T: Decodable>(endpoint: String, queryItems: [URLQueryItem], completion: @escaping (Result<T, APIError>) -> Void) {
        
        var components = URLComponents(string: Constants.baseURL + endpoint)
        
        // 1. Додаємо обов'язкові параметри (API Key, units, lang)
        var items = [
            URLQueryItem(name: "appid", value: Constants.apiKey),
            URLQueryItem(name: "units", value: Constants.units),
            URLQueryItem(name: "lang", value: "uk")
        ]
        // 2. Додаємо специфічні параметри (q=city АБО lat/lon)
        items.append(contentsOf: queryItems)
        components?.queryItems = items
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(.other(error.localizedDescription)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    completion(.failure(.cityNotFound))
                    return
                } else if httpResponse.statusCode != 200 {
                    completion(.failure(.other("HTTP Error: \(httpResponse.statusCode)")))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                
                // ДІАГНОСТИКА УСПІХУ
                print("✅ DECODE SUCCESS: Successfully decoded object of type \(T.self)")
                
                completion(.success(decodedObject))
            } catch let decodeError {
                
                // ДІАГНОСТИКА ПОМИЛКИ
                print("❌ DECODE FAILURE: Decoding failed for type \(T.self)!")
                print("JSONDecoder Error: \(decodeError)")
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("--- RECEIVED RAW JSON (for \(T.self)): ---")
                    print(jsonString.prefix(500) + "...")
                    print("--------------------------------------------------")
                }
                
                completion(.failure(.decodingError))
            }
            
        }.resume()
    }
    
    // MARK: - 1. ЗАПИТ ЗА НАЗВОЮ МІСТА (City Name) - (Стара логіка)
    
    func fetchCurrentWeather(city: String, completion: @escaping (Result<CurrentWeatherResponse, APIError>) -> Void) {
        let query = [URLQueryItem(name: "q", value: city)]
        fetchData(endpoint: "weather", queryItems: query, completion: completion)
    }
    
    func fetchForecast(city: String, completion: @escaping (Result<ForecastResponse, APIError>) -> Void) {
        let query = [URLQueryItem(name: "q", value: city)]
        fetchData(endpoint: "forecast", queryItems: query, completion: completion)
    }
    
    // MARK: - 2. 🛑 НОВІ МЕТОДИ ЗАПИТУ ЗА КООРДИНАТАМИ (CoreLocation)
    
    func fetchCurrentWeather(lat: Double, lon: Double, completion: @escaping (Result<CurrentWeatherResponse, APIError>) -> Void) {
        let query = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)")
        ]
        fetchData(endpoint: "weather", queryItems: query, completion: completion)
    }
    
    func fetchForecast(lat: Double, lon: Double, completion: @escaping (Result<ForecastResponse, APIError>) -> Void) {
        let query = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)")
        ]
        fetchData(endpoint: "forecast", queryItems: query, completion: completion)
    }
}
