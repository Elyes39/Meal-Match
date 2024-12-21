import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favorites: [FavoriteRecipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func loadFavorites() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("favorites")
                .getDocuments()
            
            favorites = snapshot.documents.compactMap { document in
                try? JSONDecoder().decode(FavoriteRecipe.self, from: JSONSerialization.data(withJSONObject: document.data()))
            }
        } catch {
            errorMessage = "Error loading favorites: \(error.localizedDescription)"
            print("Error loading favorites: \(error)")
        }
        
        isLoading = false
    }
    
    func removeFavorite(_ favorite: FavoriteRecipe) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db.collection("users")
                .document(userId)
                .collection("favorites")
                .document(favorite.id)
                .delete()
            
            favorites.removeAll { $0.id == favorite.id }
        } catch {
            print("Error removing favorite: \(error)")
        }
    }
    
    func fetchRecipeDetails(for favorite: FavoriteRecipe) async throws -> Recipe {
        return try await RecipeService.shared.fetchRecipeById(id: favorite.recipeId)
    }
} 