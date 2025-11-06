import SwiftUI

struct StatusAndErrorView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView("Оновлення даних...")
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .padding(.vertical, 10)
        } else if let errorMsg = viewModel.errorMessage {
            NeonErrorView(errorMessage: errorMsg)
        }
    }
}
