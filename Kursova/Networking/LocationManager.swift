// LocationManager.swift

import Foundation
import CoreLocation

// Протокол для зв'язку з ViewModel
protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(lat: Double, lon: Double)
    func didFailWithError()
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            delegate?.didFailWithError()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        delegate?.didUpdateLocation(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailWithError()
    }
}
