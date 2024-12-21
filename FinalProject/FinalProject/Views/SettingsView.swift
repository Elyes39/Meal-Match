import SwiftUI

struct SettingsView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        PreferencesView(homeViewModel: HomeViewModel())
                    } label: {
                        Label("Dietary Preferences", systemImage: "slider.horizontal.3")
                    }
                }
                
                Section {
                    if let email = firebaseManager.currentUser?.email {
                        HStack {
                            Label("Email", systemImage: "envelope")
                            Spacer()
                            Text(email)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(role: .destructive, action: {
                        try? firebaseManager.signOut()
                    }) {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
} 