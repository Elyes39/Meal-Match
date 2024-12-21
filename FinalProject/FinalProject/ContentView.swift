//
//  ContentView.swift
//  FinalProject
//
//  Created by Elyes Seffar on 12/8/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        Group {
            if firebaseManager.isLoggedIn {
                TabView {
                    HomeFeedView()
                        .tabItem {
                            Label("Discover", systemImage: "fork.knife")
                        }
                    
                    FavoritesView()
                        .tabItem {
                            Label("Favorites", systemImage: "heart.fill")
                        }
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .preferredColorScheme(.dark)
            } else {
                LoginView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}

#Preview {
    ContentView()
}
