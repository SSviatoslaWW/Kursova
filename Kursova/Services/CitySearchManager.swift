import Foundation
import MapKit
import Combine

class CitySearchManager: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {

    //текст що вводить користувач
    @Published var queryFragment: String = ""
    //Резульати пошуку який змінюється лише в цьому класі але читати можна з будь якої точки програми
    @Published private(set) var results: [CitySearchResult] = []

    //Асистент який шукає міста
    private let completer = MKLocalSearchCompleter()
    //Зберігаємо підписку на зміну тексту Combine
    private var cancellable: AnyCancellable?
    
    override init() {
        super.init()
        //Призначаємо делегата до асистента
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
    //Викликається коли пошук пройшов успішно
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
    //Викликається коли видається помилка під час пошуку
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
