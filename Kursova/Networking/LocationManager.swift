// LocationManager.swift

import Foundation
import CoreLocation // ⬅️ Імпорт фреймворку для роботи з геолокацією

// MARK: - Location Manager Delegate Protocol

/// Протокол для зворотного зв'язку з ViewModel.
/// Використовується для сповіщення про успішне отримання координат або про помилку/відмову.
protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(lat: Double, lon: Double) // Успішно отримані координати
    func didFailWithError()                       // Помилка або відмова в доступі
}

// MARK: - Location Manager Class

/// Клас, що керує запитом дозволів геолокації та отриманням координат.
/// Успадковується від NSObject та ObservableObject для використання в SwiftUI.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    //  Основний об'єкт CoreLocation
    private let manager = CLLocationManager()
    
    // 🤝 Делегат для зв'язку з ViewModel
    weak var delegate: LocationManagerDelegate?

    override init() {
        super.init()
        manager.delegate = self
        // Встановлюємо точність: kCLLocationAccuracyReduced - менше навантаження на батарею
        manager.desiredAccuracy = kCLLocationAccuracyReduced
    }
    
    /// Запускає запит на дозвіл та ініціює пошук поточної локації.
    func requestLocation() {
        // Запит дозволу "коли використовується програма"
        manager.requestWhenInUseAuthorization()
        
        // Якщо дозвіл вже є, одразу запитуємо локацію.
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    // =============================================================
    // MARK: - CLLocationManagerDelegate (Обробка Системних Подій)
    // =============================================================
    
    /// Обробляє зміну статусу дозволу на використання геолокації.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Дозвіл надано: починаємо пошук локації
            manager.requestLocation()
            
        case .denied, .restricted:
            // Дозвіл відхилено або обмежено: повідомляємо ViewModel для резервного міста (Львів)
            delegate?.didFailWithError()
            
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    /// Обробляє успішне отримання нової локації.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Успіх: передаємо координати ViewModel
        delegate?.didUpdateLocation(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        
        // Зупиняємо оновлення після першого успішного отримання
        manager.stopUpdatingLocation()
    }

    /// Обробляє помилки при спробі отримати локацію (наприклад, GPS недоступний).
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Помилка: повідомляємо ViewModel для резервного пошуку
        delegate?.didFailWithError()
    }
}
