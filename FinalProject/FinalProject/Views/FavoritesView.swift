import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading favorites...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.favorites.isEmpty {
                    Text("No favorites yet")
                        .font(.title2)
                } else {
                    List {
                        ForEach(viewModel.favorites) { favorite in
                            FavoriteRecipeRow(favorite: favorite)
                        }
                        .onDelete { indexSet in
                            Task {
                                if let index = indexSet.first {
                                    await viewModel.removeFavorite(viewModel.favorites[index])
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .task {
                await viewModel.loadFavorites()
            }
        }
    }
}

struct FavoriteRecipeRow: View {
    let favorite: FavoriteRecipe
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var recipe: Recipe?
    @State private var showError = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationLink {
            Group {
                if let recipe = recipe {
                    RecipeDetailsView(recipe: recipe)
                } else {
                    ProgressView("Loading recipe details...")
                        .task {
                            await loadRecipeDetails()
                        }
                }
            }
        } label: {
            HStack {
                AsyncImage(url: favorite.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(favorite.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Label("\(favorite.readyInMinutes) min", systemImage: "clock")
                        Spacer()
                        Label("\(favorite.servings) servings", systemImage: "person.2")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Failed to load recipe details")
        }
    }
    
    private func loadRecipeDetails() async {
        guard recipe == nil else { return }
        isLoading = true
        
        do {
            recipe = try await viewModel.fetchRecipeDetails(for: favorite)
        } catch {
            showError = true
            print("Error loading recipe details: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    FavoritesView()
} 