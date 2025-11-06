import Foundation

struct SystemInfo: Decodable {
    let country: String // Код країни
    let sunrise: Int    // Час сходу сонця
    let sunset: Int     // Час заходу сонця
}
