import Foundation
import MapKit
import Combine



class CitySearchManager: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published var queryFragment: String = ""
    @Published private(set) var results: [CitySearchResult] = []
    @Published var statusMessage: String? = nil
    
    private let completer = MKLocalSearchCompleter()
    private var cancellable: AnyCancellable?
    
    // Зберігаємо активні запити перевірки, щоб скасовувати їх
    private var activeValidations: [MKLocalSearch] = []
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
        
        cancellable = $queryFragment
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main) // Оптимальна затримка
            .removeDuplicates()
            .sink { [weak self] fragment in
                guard let self = self else { return }
                
                // Скасовуємо всі попередні перевірки, якщо вони ще тривають
                self.cancelActiveValidations()
                
                if fragment.isEmpty {
                    self.results = []
                    self.statusMessage = nil
                    self.completer.cancel()
                } else {
                    self.statusMessage = nil
                    self.completer.queryFragment = fragment
                }
            }
    }
    
    // Допоміжна функція для очищення черги
    private func cancelActiveValidations() {
        activeValidations.forEach { $0.cancel() }
        activeValidations.removeAll()
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let rawResults = completer.results
        
        if rawResults.isEmpty {
            self.results = []
            self.statusMessage = "Місто не знайдено"
            return
        }
        
        verifyResults(rawResults)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Ігноруємо помилку скасування (вона нормальна при швидкому друці)
        if (error as NSError).code != -10 {
            self.statusMessage = "Помилка з'єднання"
        }
    }
    
    private func verifyResults(_ completions: [MKLocalSearchCompletion]) {
        // 1. ЛІМІТ: Беремо тільки ТОП-4 найімовірніших результати
        var candidates = Array(completions.prefix(4))
        
        // Якщо починається з цифри - це не місто
        candidates = candidates.filter {
            let firstChar = $0.title.first
            return firstChar != nil && !firstChar!.isNumber
        }
        
        if candidates.isEmpty {
            self.results = []
            self.statusMessage = "Місто не знайдено"
            return
        }
        
        let group = DispatchGroup()
        var verifiedCities: [CitySearchResult] = []
        // Синхронізація доступу до масиву verifiedCities
        let lock = NSLock()
        
        for completion in candidates {
            group.enter()
            
            let searchRequest = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            
            // Додаємо в список активних, щоб мати змогу скасувати
            self.activeValidations.append(search)
            
            search.start { [weak self] response, error in
                defer { group.leave() }
                
                // Якщо запит скасовано або помилка - виходимо
                guard let self = self, error == nil, let item = response?.mapItems.first else { return }
                
                // ПЕРЕВІРКА НА МІСТО
                if item.placemark.locality != nil && item.placemark.thoroughfare == nil {
                    
                    let city = CitySearchResult(
                        title: item.placemark.locality ?? item.name ?? "",
                        subtitle: self.formatSubtitle(placemark: item.placemark),
                        coordinate: item.placemark.coordinate
                    )
                    
                    lock.lock()
                    verifiedCities.append(city)
                    lock.unlock()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            // Очищаємо список виконаних запитів
            self.activeValidations.removeAll()
            
            let finalResults = Array(Set(verifiedCities)).sorted(by: { $0.title < $1.title })
            self.results = finalResults
            
            if finalResults.isEmpty {
                // Показуємо повідомлення тільки якщо ми справді шукали, але відфільтрували все
                self.statusMessage = "Місто не знайдено"
            } else {
                self.statusMessage = nil
            }
        }
    }
    
    private func formatSubtitle(placemark: MKPlacemark) -> String {
        var parts: [String] = []
        if let admin = placemark.administrativeArea { parts.append(admin) }
        if let country = placemark.country { parts.append(country) }
        return parts.joined(separator: ", ")
    }
}
