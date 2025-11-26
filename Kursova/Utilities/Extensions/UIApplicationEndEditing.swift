import SwiftUI

// MARK: - Допоміжне розширення для закриття клавіатури
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
