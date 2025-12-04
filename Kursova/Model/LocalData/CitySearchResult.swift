import Foundation
import MapKit

//Випадаючий список модель
struct CitySearchResult: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    
    // Потрібно для Hashable (оскільки coordinate не є Hashable)
    static func == (lhs: CitySearchResult, rhs: CitySearchResult) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
