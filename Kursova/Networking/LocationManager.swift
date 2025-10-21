// LocationManager.swift

import Foundation
import CoreLocation

// ❗️ 1. Визначено кастомну помилку для більшої ясності
enum LocationError: Error {
    case accessDenied
    case failed
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    private var locationCompletion: ((Result<CLLocationCoordinate2D, LocationError>) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
    }
    
    func requestLocation(completion: @escaping (Result<CLLocationCoordinate2D, LocationError>) -> Void) {
        self.locationCompletion = completion
        
        manager.requestWhenInUseAuthorization()
        
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    // =============================================================
    // MARK: - CLLocationManagerDelegate (Обробка Системних Подій)
    // =============================================================
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
            
        case .denied, .restricted:
            locationCompletion?(.failure(.accessDenied))
            locationCompletion = nil // Очищуємо, щоб не викликати повторно
            
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        locationCompletion?(.success(location.coordinate))
        locationCompletion = nil // Очищуємо
        
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCompletion?(.failure(.failed))
        locationCompletion = nil // Очищуємо
    }
}
