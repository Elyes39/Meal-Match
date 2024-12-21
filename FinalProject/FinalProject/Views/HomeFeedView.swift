import SwiftUI

struct HomeFeedView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Loading recipes...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Try Again") {
                            Task {
                                await viewModel.refreshRecipes()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else if viewModel.recipes.isEmpty {
                    VStack {
                        Text("No more recipes")
                            .font(.title2)
                        Button("Load More") {
                            Task {
                                await viewModel.loadRecipes()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    VStack {
                        ZStack {
                            ForEach(viewModel.recipes) { recipe in
                                RecipeCard(
                                    recipe: recipe,
                                    onSwipeLeft: {
                                        viewModel.removeRecipe(recipe)
                                    },
                                    onSwipeRight: {
                                        viewModel.saveRecipe(recipe)
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                        
                        Text("Swipe right to save, left to skip")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                }
            }
            .navigationTitle("MealMatch")
            .task {
                await viewModel.loadRecipes()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showPreferences = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showPreferences) {
                PreferencesView(homeViewModel: viewModel)
            }
        }
    }
}

#Preview {
    HomeFeedView()
} 
