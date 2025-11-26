import SwiftUI

/// Неонове повідомлення про помилку
struct NeonErrorView: View {
    let errorMessage: String
    
    // Неонові кольори для помилки (жовто-червоні)
    let errorGradientColors: [Color] = AppColors.error
    
    var body: some View {
        VStack(spacing: 10) {
        
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)
                .shadow(color: .orange, radius: 10) // Неонове світіння іконки
            
            
            Text(errorMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .background(Color.black.opacity(0.6))
        .cornerRadius(20)
        // Неонова рамка
        .overlay(
            NeonBorder(
                shape: RoundedRectangle(cornerRadius: 20),
                colors: errorGradientColors,
                lineWidth: 4,
                blurRadius: 6
            )
        )
        // Центрування на екрані
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 40) 
    }
}
