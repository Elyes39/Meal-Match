import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    
    @State private var offset = CGSize.zero
    private let cardWidth = UIScreen.main.bounds.width - 40
    private let contentPadding: CGFloat = 20
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
            
            // Image layer
            AsyncImage(url: recipe.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .clipped()
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content overlay
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                Text(recipe.title)
                    .font(.title2)
                    .bold()
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
                    .frame(width: cardWidth - (contentPadding * 2), alignment: .leading)
                
                HStack(spacing: 16) {
                    Label {
                        Text("\(recipe.readyInMinutes) min")
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    } icon: {
                        Image(systemName: "clock")
                    }
                    
                    Spacer()
                    
                    Label {
                        Text("\(recipe.servings) servings")
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    } icon: {
                        Image(systemName: "person.2")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .frame(width: cardWidth - (contentPadding * 2))
            }
            .padding(.horizontal, contentPadding)
            .padding(.vertical, 16)
        }
        .frame(width: cardWidth, height: 400)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .offset(x: offset.width, y: 0)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        withAnimation {
                            offset.width = 500
                            onSwipeRight()
                        }
                    } else if gesture.translation.width < -100 {
                        withAnimation {
                            offset.width = -500
                            onSwipeLeft()
                        }
                    } else {
                        withAnimation {
                            offset = .zero
                        }
                    }
                }
        )
    }
}

#Preview {
    RecipeCard(
        recipe: Recipe(
            id: 1,
            title: "Spaghetti Carbonara",
            image: "https://spoonacular.com/recipeImages/716429-556x370.jpg",
            readyInMinutes: 30,
            servings: 4,
            sourceUrl: "https://example.com",
            summary: "A classic Italian pasta dish",
            cuisines: ["Italian"],
            dishTypes: ["main course", "dinner"],
            diets: ["pescatarian"],
            instructions: "Cook pasta...",
            extendedIngredients: []
        ),
        onSwipeLeft: {},
        onSwipeRight: {}
    )
    .padding()
} 