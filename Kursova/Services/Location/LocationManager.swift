// LocationManager.swift

import Foundation
import CoreLocation

enum LocationError: Error {
    case accessDenied //користувач не дозволив геолокацію
    case failed //користувач не дозволив геолокацію
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    
    //колбек що викликається коли локація отримана
    private var locationCompletion: ((Result<CLLocationCoordinate2D, LocationError>) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        // kCLLocationAccuracyThreeKilometers зазвичай найшвидший варіант, достатній для погоди.
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    func requestLocation(completion: @escaping (Result<CLLocationCoordinate2D, LocationError>) -> Void) {
        // зберігаємо колбек
        self.locationCompletion = completion
        
        //Явно зупиняємо попередні оновлення перед новим запитом
        manager.stopUpdatingLocation()
        //Запит на дозвіл використання геолокації
        manager.requestWhenInUseAuthorization()
        
        // Перевіряємо статус авторизації
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Все ок, запускаємо запит
            manager.requestLocation()
            
        case .denied, .restricted:
            // Одразу повертаємо помилку, не чекаючи делегата
            completion(.failure(.accessDenied))
            self.locationCompletion = nil
            
        case .notDetermined:
            // Чекаємо на рішення користувача (спрацює метод делегата didChangeAuthorization)
            break
            
        @unknown default:
            completion(.failure(.failed))
            self.locationCompletion = nil
        }
    }
    

    //Викликається коли користувач змінює дозвіл до геолокації
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Якщо ми чекали на дозвіл, і його дали — запускаємо запит
            if locationCompletion != nil {
                manager.requestLocation()
            }
            
        case .denied, .restricted:
            locationCompletion?(.failure(.accessDenied))
            locationCompletion = nil
            
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    //викликається коли локація отримана
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Беремо останню (найсвіжішу) локацію з масиву
        guard let location = locations.last else { return }
        
        // Перевіряємо, чи локація не надто стара
        if Date().timeIntervalSince(location.timestamp) < 60 {
             locationCompletion?(.success(location.coordinate))
             locationCompletion = nil
             manager.stopUpdatingLocation()
        }
    }
    //Викликається коли не вдалося отримати локацію
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
        
        // Ігноруємо помилку, якщо це kCLErrorLocationUnknown (система ще шукає)
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        locationCompletion?(.failure(.failed))
        locationCompletion = nil
        manager.stopUpdatingLocation()
    }
}


//Визначення міста за координатами
extension LocationManager {
    
    func resolveCityName(
        latitude: Double,
        longitude: Double,
        completion: @escaping (String?) -> Void
    ) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            completion(placemarks?.first?.locality)
        }
    }
}
