// Networking/WeatherService.swift

import Foundation

class WeatherService {
    
    private func fetchData<T: Decodable>(endpoint: String, queryItems: [URLQueryItem], completion: @escaping (Result<T, APIError>) -> Void) {
        
        var components = URLComponents(string: Constants.baseURL + endpoint)
        
        var baseQueryItems = [
            URLQueryItem(name: "appid", value: Constants.apiKey),     //  API ключ
            URLQueryItem(name: "units", value: Constants.units),      //  Метричні одиниці (°C)
            URLQueryItem(name: "lang", value: "uk")                   //  Мова відповіді (Українська)
        ]
        
        baseQueryItems.append(contentsOf: queryItems)
        components?.queryItems = baseQueryItems
        
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
                let statusCode = httpResponse.statusCode
                
                if statusCode == 404 {
                    completion(.failure(.cityNotFound))
                    return
                } else if statusCode != 200 {
                    completion(.failure(.other("HTTP Error: \(statusCode)")))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                
                completion(.success(decodedObject)) // Успіх
            } catch  {
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
    
    //функція для формування запиту координат
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
