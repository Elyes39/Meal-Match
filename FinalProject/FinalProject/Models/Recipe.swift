import Foundation

struct Recipe: Identifiable, Codable {
    let id: Int
    let title: String
    let image: String
    let readyInMinutes: Int
    let servings: Int
    let sourceUrl: String?
    let summary: String
    let cuisines: [String]
    let dishTypes: [String]
    let diets: [String]
    let instructions: String?
    let extendedIngredients: [Ingredient]
    
    // Add imageURL computed property
    var imageURL: URL? {
        URL(string: image)
    }
    
    // Computed property to get clean instructions without HTML tags
    var cleanInstructions: String {
        return instructions?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) ?? ""
    }
    
    // Computed property to get clean summary without HTML tags
    var cleanSummary: String {
        return summary.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}

struct Ingredient: Codable {
    let id: Int
    let name: String
    let amount: Double
    let unit: String
    let original: String
    
    // Computed property to get a formatted measurement string
    var measurement: String {
        return "\(amount) \(unit)"
    }
}