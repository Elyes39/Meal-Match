import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var showPreferences = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var preferences: UserPreferences?
    
    init() {
        Task {
            await loadRecipes()
        }
    }
    
    func loadRecipes() async {
        isLoading = true
        errorMessage = nil
        
        // Load preferences first
        await loadPreferences()
        
        do {
            print("Loading recipes with preferences: \(String(describing: preferences))")
            recipes = try await RecipeService.shared.fetchRecipes(preferences: preferences)
            print("Loaded \(recipes.count) recipes")
        } catch {
            errorMessage = "Error loading recipes: \(error.localizedDescription)"
            print("Error loading recipes: \(error)")
        }
        
        isLoading = false
    }
    
    private func loadPreferences() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let document = try await db.collection("userPreferences").document(userId).getDocument()
            if let data = document.data(),
               let jsonData = try? JSONSerialization.data(withJSONObject: data),
               let loadedPreferences = try? JSONDecoder().decode(UserPreferences.self, from: jsonData) {
                print("Loaded preferences: \(loadedPreferences)")
                self.preferences = loadedPreferences
            }
        } catch {
            print("Error loading preferences: \(error)")
        }
    }
    
    func removeRecipe(_ recipe: Recipe) {
        withAnimation {
            recipes.removeAll { $0.id == recipe.id }
        }
        
        if recipes.isEmpty {
            Task {
                await loadRecipes()
            }
        }
    }
    
    func saveRecipe(_ recipe: Recipe) {
        Task {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            let favorite = FavoriteRecipe(recipe: recipe)
            
            do {
                try await db.collection("users")
                    .document(userId)
                    .collection("favorites")
                    .document(favorite.id)
                    .setData(try JSONEncoder().encode(favorite).jsonObject())
                
                print("Recipe saved to favorites")
            } catch {
                print("Error saving favorite: \(error)")
            }
            
            removeRecipe(recipe)
        }
    }
    
    func refreshRecipes() async {
        await loadRecipes()
    }
}

extension HomeViewModel {
    static var preview: HomeViewModel {
        let viewModel = HomeViewModel()
        viewModel.recipes = [
            Recipe(
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
            Recipe(
                id: 2,
                title: "Chicken Tikka Masala",
                image: "https://spoonacular.com/recipeImages/716429-556x370.jpg",
                readyInMinutes: 45,
                servings: 6,
                sourceUrl: "https://example.com",
                summary: "A popular Indian curry",
                cuisines: ["Indian"],
                dishTypes: ["main course", "dinner"],
                diets: [],
                instructions: "Marinate chicken...",
                extendedIngredients: []
            )
        ]
        return viewModel
    }
}

// Add this extension to help with Firestore conversion
extension Data {
    func jsonObject() throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: self) as? [String: Any] ?? [:]
    }
} 
