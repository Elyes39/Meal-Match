import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var preferences = UserPreferences()
    @State private var isLoading = false
    @ObservedObject var homeViewModel: HomeViewModel
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            List {
                Section("Dietary Preferences") {
                    ForEach(["Vegetarian", "Vegan", "Gluten Free", "Ketogenic", "Paleo"], id: \.self) { diet in
                        Toggle(diet, isOn: Binding(
                            get: { preferences.diets.contains(diet) },
                            set: { isOn in
                                if isOn {
                                    preferences.diets.append(diet)
                                } else {
                                    preferences.diets.removeAll { $0 == diet }
                                }
                            }
                        ))
                    }
                }
                
                Section("Food Intolerances") {
                    ForEach(["Dairy", "Egg", "Gluten", "Peanut", "Seafood", "Shellfish", "Soy", "Tree Nut", "Wheat"], id: \.self) { intolerance in
                        Toggle(intolerance, isOn: Binding(
                            get: { preferences.intolerances.contains(intolerance) },
                            set: { isOn in
                                if isOn {
                                    preferences.intolerances.append(intolerance)
                                } else {
                                    preferences.intolerances.removeAll { $0 == intolerance }
                                }
                            }
                        ))
                    }
                }
                
                Section("Preferred Cuisines") {
                    ForEach(["Italian", "Mexican", "Chinese", "Indian", "Japanese", "Thai", "Mediterranean", "American", "French"], id: \.self) { cuisine in
                        Toggle(cuisine, isOn: Binding(
                            get: { preferences.cuisines.contains(cuisine) },
                            set: { isOn in
                                if isOn {
                                    preferences.cuisines.append(cuisine)
                                } else {
                                    preferences.cuisines.removeAll { $0 == cuisine }
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Preferences")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await savePreferences()
                            await homeViewModel.loadRecipes()
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadPreferences()
            }
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
        }
    }
    
    private func loadPreferences() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            let document = try await db.collection("userPreferences").document(userId).getDocument()
            if let data = document.data(),
               let jsonData = try? JSONSerialization.data(withJSONObject: data),
               let loadedPreferences = try? JSONDecoder().decode(UserPreferences.self, from: jsonData) {
                preferences = loadedPreferences
            }
        } catch {
            print("Error loading preferences: \(error)")
        }
        
        isLoading = false
    }
    
    private func savePreferences() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            let data = try JSONEncoder().encode(preferences)
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                try await db.collection("userPreferences").document(userId).setData(jsonObject)
            }
        } catch {
            print("Error saving preferences: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    PreferencesView(homeViewModel: HomeViewModel())
}