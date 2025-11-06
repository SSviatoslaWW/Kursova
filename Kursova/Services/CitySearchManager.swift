// ViewModel/CitySearchManager.swift

import Foundation
import MapKit
import Combine

class CitySearchManager: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published var queryFragment: String = ""
    @Published private(set) var results: [CitySearchResult] = []
    
    private let completer = MKLocalSearchCompleter()
    private var cancellable: AnyCancellable?
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address // Шукаємо населені пункти
        
        // Додаємо невелику затримку перед пошуком, щоб не перевантажувати систему при швидкому наборі
        cancellable = $queryFragment
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { fragment in
                if fragment.isEmpty {
                    self.results = []
                } else {
                    self.completer.queryFragment = fragment
                }
            }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results.filter { result in
            // 1. Має бути підзаголовок (країна/регіон)
            guard !result.subtitle.isEmpty else { return false }
            
            // 2. Відкидаємо явні адміністративні одиниці, якщо вони не схожі на міста
            // Це евристика: зазвичай міста мають кому в підзаголовку (наприклад, "Каліфорнія, США")
            let isLikelyCity = result.subtitle.contains(",") || !result.subtitle.contains("Administrative")
            
            return isLikelyCity
        }.map {
            CitySearchResult(title: $0.title, subtitle: $0.subtitle)
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Можна додати обробку помилок, якщо потрібно
        print("Search error: \(error.localizedDescription)")
    }
}

struct CitySearchResult: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
}
