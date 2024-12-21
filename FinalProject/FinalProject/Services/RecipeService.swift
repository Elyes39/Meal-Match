import Foundation
import FirebaseAuth
import FirebaseFirestore

// Add RecipeError enum
enum RecipeError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(statusCode: Int)
    case decodingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Invalid API key or unauthorized access"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

struct UserPreferences: Codable {
    var diets: [String]
    var intolerances: [String]
    var cuisines: [String]
    
    init(diets: [String] = [], intolerances: [String] = [], cuisines: [String] = []) {
        self.diets = diets
        self.intolerances = intolerances
        self.cuisines = cuisines
    }
}

struct SpoonacularError: Codable {
    let status: String
    let code: Int
    let message: String
}

struct RecipeResponse: Codable {
    let results: [Recipe]
    let offset: Int
    let number: Int
    let totalResults: Int
}

class RecipeService {
    static let shared = RecipeService()
    private let apiKey = "e43fee8e205d4de5bff41cac471af607"
    private let baseURL = "https://api.spoonacular.com/recipes"
    
    private init() {}
    
    func fetchRecipes(preferences: UserPreferences?) async throws -> [Recipe] {
        var components = URLComponents(string: "https://api.spoonacular.com/recipes/complexSearch")!
        
        // Build base query parameters
        var queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "number", value: "5"),
            URLQueryItem(name: "addRecipeInformation", value: "true"),
            URLQueryItem(name: "sort", value: "random"),
            URLQueryItem(name: "fillIngredients", value: "true")
        ]
        
        // Add all preference filters if present
        if let preferences = preferences {
            // Add diet preferences
            if !preferences.diets.isEmpty {
                queryItems.append(URLQueryItem(name: "diet", value: preferences.diets.joined(separator: ",")))
            }
            
            // Add intolerances
            if !preferences.intolerances.isEmpty {
                queryItems.append(URLQueryItem(name: "intolerances", value: preferences.intolerances.joined(separator: ",")))
            }
            
            // Add cuisines
            if !preferences.cuisines.isEmpty {
                queryItems.append(URLQueryItem(name: "cuisine", value: preferences.cuisines.joined(separator: ",")))
            }
        }
        
        components.queryItems = queryItems
        
        // Print the URL for debugging
        print("Making request to URL: \(components.url?.absoluteString ?? "")")
        
        guard let url = components.url else {
            throw RecipeError.invalidURL
        }
        
        // Add error handling for API response
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RecipeError.invalidResponse
        }
        
        // Check for API errors
        if httpResponse.statusCode == 401 {
            throw RecipeError.unauthorized
        }
        
        if httpResponse.statusCode != 200 {
            throw RecipeError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // Decode the response
        do {
            let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
            return recipeResponse.results
        } catch {
            print("Decoding error: \(error)")
            throw RecipeError.decodingError(error)
        }
    }
    
    func fetchRecipeById(id: Int) async throws -> Recipe {
        var components = URLComponents(string: "\(baseURL)/\(id)/information")!
        
        let queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw RecipeError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RecipeError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw RecipeError.unauthorized
        }
        
        if httpResponse.statusCode != 200 {
            throw RecipeError.serverError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(Recipe.self, from: data)
    }
}
