import SwiftUI

struct CityCardRow: View {
    let location: FavoriteLocation
    let index: Int
    let isEditing: Bool
    @ObservedObject var favoritesVM: FavoritesViewModel
    let onSelect: () -> Void
    
    let deleteButtonColors: [Color] = AppColors.delete
    let cardNeonColors: [Color] = AppColors.cyanPurple
    
    var body: some View {
        HStack(spacing: 15) {
            // Кнопка видалення зліва
            ZStack {
                Button(action: {
                    guard isEditing else { return }
                    withAnimation(.spring()) {
                        favoritesVM.removeLocation(at: IndexSet(integer: index))
                    }
                }) {
                    ZStack {
                        NeonBorder(
                            shape: Circle(),
                            colors: deleteButtonColors,
                            lineWidth: 3,
                            blurRadius: 4
                        )
                        .frame(width: 50, height: 50)
                        
                        Image(systemName: "trash.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                            .shadow(color: .red.opacity(0.8), radius: 5, x: 0, y: 0)
                    }
                }
            }
            .frame(width: isEditing ? 50 : 0, height: 50, alignment: .leading)
            .opacity(isEditing ? 1 : 0)
            
            // Картка міста
            Button(action: {
                if !isEditing { onSelect() }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .shadow(color: .white.opacity(0.7), radius: 7, x: 0, y: 0)
                        
                        Text(location.country)
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 0)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.up.and.down.circle")
                                .font(.caption)
                            Text(String(format: "%.2f°", location.lat))
                                .font(.callout).bold()
                        }
                        
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.left.and.right.circle")
                                .font(.caption)
                            Text(String(format: "%.2f°", location.lon))
                                .font(.callout).bold()
                        }
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .white.opacity(0.6), radius: 5, x: 0, y: 0)
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(
                    NeonBorder(
                        shape: RoundedRectangle(cornerRadius: 16),
                        colors: cardNeonColors,
                        lineWidth: 5,
                        blurRadius: 5
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        // Плавна анімація переходу в режим редагування
        .animation(.spring(), value: isEditing)
    }
}
