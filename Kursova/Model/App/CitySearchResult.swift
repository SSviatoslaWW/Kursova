import Foundation

struct CitySearchResult: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
}
