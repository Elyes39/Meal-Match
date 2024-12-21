import Foundation
import FirebaseFirestore

struct FavoriteRecipe: Identifiable, Codable {
    let id: String  // Firestore document ID
    let recipeId: Int
    let title: String
    let image: String
    let readyInMinutes: Int
    let servings: Int
    
    var imageURL: URL? {
        URL(string: image)
    }
    
    init(id: String = UUID().uuidString, recipe: Recipe) {
        self.id = id
        self.recipeId = recipe.id
        self.title = recipe.title
        self.image = recipe.image
        self.readyInMinutes = recipe.readyInMinutes
        self.servings = recipe.servings
    }
} 