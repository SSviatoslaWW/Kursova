import SwiftUI

struct FavoritesEmptyStateView: View {
    var body: some View {
        Text("Міста, які ви додасте до улюблених, з'являться тут.")
            .font(.headline)
            .multilineTextAlignment(.center)
            .foregroundColor(.white.opacity(0.8))
            .padding(.top, 50)
            .padding(.horizontal)
    }
}
