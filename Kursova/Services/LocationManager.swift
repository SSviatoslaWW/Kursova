// LocationManager.swift

import Foundation
import CoreLocation

enum LocationError: Error {
    case accessDenied
    case failed
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // ЗМІНА 1: Робимо manager доступним для читання ззовні (для доступу до .location)
    // або можна залишити private і додати публічний метод getLastLocation()
    let manager = CLLocationManager()
    
    private var locationCompletion: ((Result<CLLocationCoordinate2D, LocationError>) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        // kCLLocationAccuracyThreeKilometers зазвичай найшвидший варіант, достатній для погоди.
        // kCLLocationAccuracyReduced теж ок, але він дуже неточний (1-20км).
        // Спробуйте ThreeKilometers для балансу швидкості/точності.
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    func requestLocation(completion: @escaping (Result<CLLocationCoordinate2D, LocationError>) -> Void) {
        // ЗМІНА 2: Скасовуємо попередній completion, якщо він був, щоб уникнути витоків або подвійних викликів
        self.locationCompletion = completion
        
        // ЗМІНА 3: Явно зупиняємо попередні оновлення перед новим запитом
        manager.stopUpdatingLocation()
        
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
            // Нічого не робимо тут, запит буде в didChangeAuthorization
            break
            
        @unknown default:
            completion(.failure(.failed))
            self.locationCompletion = nil
        }
    }
    
    // =============================================================
    // MARK: - CLLocationManagerDelegate
    // =============================================================
    
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Беремо останню (найсвіжішу) локацію з масиву
        guard let location = locations.last else { return }
        
        // Перевіряємо, чи локація не надто стара (наприклад, старша за 1 хвилину)
        // Це допомагає уникнути використання дуже старих кешованих даних при запуску
        if Date().timeIntervalSince(location.timestamp) < 60 {
             locationCompletion?(.success(location.coordinate))
             locationCompletion = nil
             manager.stopUpdatingLocation()
        } else {
            // Якщо локація стара, ми можемо нічого не робити і чекати наступного оновлення,
            // але requestLocation() зазвичай сам повертає тільки одну свіжу.
            // Про всяк випадок, якщо прийшла стара, можна її все одно повернути,
            // щоб не блокувати користувача вічним очікуванням.
             locationCompletion?(.success(location.coordinate))
             locationCompletion = nil
             manager.stopUpdatingLocation()
        }
    }
    
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
