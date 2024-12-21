import SwiftUI

struct RecipeDetailsView: View {
    let recipe: Recipe
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Recipe Image
                    AsyncImage(url: recipe.imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(width: geometry.size.width)
                    .frame(height: 300)
                    .clipped()
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Recipe Info
                        HStack {
                            Label("\(recipe.readyInMinutes) min", systemImage: "clock")
                            Spacer()
                            Label("\(recipe.servings) servings", systemImage: "person.2")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        // Diets and Cuisines
                        VStack(alignment: .leading, spacing: 12) {
                            if !recipe.diets.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(recipe.diets, id: \.self) { diet in
                                            Text(diet)
                                                .font(.caption)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.green.opacity(0.15))
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                            }
                            
                            if !recipe.cuisines.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(recipe.cuisines, id: \.self) { cuisine in
                                            Text(cuisine)
                                                .font(.caption)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.blue.opacity(0.15))
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Summary
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(recipe.cleanSummary)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .frame(width: geometry.size.width - 32, alignment: .leading)
                        }
                        
                        // Ingredients
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients")
                                .font(.title2)
                                .fontWeight(.bold)
                            ForEach(recipe.extendedIngredients, id: \.id) { ingredient in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                    Text(ingredient.original)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: geometry.size.width - 48, alignment: .leading)
                                }
                            }
                        }
                        
                        // Instructions
                        if let instructions = recipe.instructions, !instructions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Instructions")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text(recipe.cleanInstructions)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .frame(width: geometry.size.width - 32, alignment: .leading)
                            }
                        }
                        
                        // Source Link
                        if let sourceUrl = recipe.sourceUrl, let url = URL(string: sourceUrl) {
                            Link(destination: url) {
                                Text("View Original Recipe")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 12)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
                .padding(.bottom, 24)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
    }
} 