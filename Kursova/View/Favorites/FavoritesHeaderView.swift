import SwiftUI

struct FavoritesHeaderView: View {
    @Binding var isEditing: Bool
    let showEditButton: Bool
    var onGeolocationTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Улюблені")
                    .font(.largeTitle).bold()
                    .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 0)
                Spacer()
                
                if showEditButton {
                    Button(isEditing ? "Готово" : "Змінити") {
                        withAnimation(.spring()) {
                            isEditing.toggle()
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 0)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            
            HStack(alignment: .center) {
                Spacer()
                Button(action: onGeolocationTap) {
                    HStack(spacing: 10) {
                        Image(systemName: "location.fill")
                            .font(.body)
                            .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 0)
                        Text("Моя Геолокація")
                            .font(.body).bold()
                            .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 0)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            AnimatedNeonBorder(
                                shape: RoundedRectangle(cornerRadius: 25.0),
                                colors: [.cyan, .blue, .purple, .cyan],
                                lineWidth: 3,
                                blurRadius: 6
                            )
                        }
                    )
                    .cornerRadius(25.0)
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 5)
                Spacer()
            }
        }
        .padding(.top, 50)
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .animation(.spring(), value: showEditButton)
    }
}
